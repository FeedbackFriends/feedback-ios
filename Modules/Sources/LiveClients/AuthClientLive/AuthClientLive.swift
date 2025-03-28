import Foundation
import Logger
import ComposableArchitecture
import FirebaseAuth
import Helpers

actor UserStateStream {
    private var continuation: AsyncStream<UserState>.Continuation?
    
    func yield(_ state: UserState) {
        if continuation == nil {
            @Dependency(\.logClient) var logger
            logger.log(.error, "UserStateStream yielded but no one is listening")
        }
        continuation?.yield(state)
    }
    
    func stream() -> AsyncStream<UserState> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }
}

public extension AuthClient {
    
    static var live: Self  {
        @Dependency(\.logClient) var logger
        let stateStream = UserStateStream()
        let firebaseService = FirebaseService()
        return Self.init(
            setupStateListener: {
//                _ = Auth.auth().addStateDidChangeListener { auth, optionalUser in
//                    
//                    let userState: UserState = {
//                        guard let user = optionalUser.optional else { return .loggedOut }
//                        return user.isAnonymous ? .anonymous : .authenticated
//                    }()
//                    Task { [stateStream] in
//                        await stateStream.yield(userState)
//                    }
//                }
            },
            signInAnonymously: {
                guard let _ = Auth.auth().currentUser else {
                    logger.log("🔥 Firebase signInAnonymously: Signing in anonymously since no user was logged in before")
                    try await Auth.auth().signInAnonymously()
                    return
                }
                logger.log(.error,"🔥 Firebase signInAnonymously: Sign in anonymously called but user was already logged in.")
            },
            fetchCustomRole: {
                guard let currentUser = Auth.auth().currentUser else {
                    throw AuthenticationError.notSignedIn
                }
                guard let role = try await currentUser.getIDTokenResult().claims["role"] as? String else {
                    logger.log("🔥 Firebase user loggedin: Logged in user, but no custom roles found")
                    return nil
                }
                
                if role == "Manager" {
                    logger.log("🔥 Firebase user loggedin: Manager role found")
                    return Role.manager
                } else if role == "Participant" {
                    logger.log("🔥 Firebase user loggedin: Participant role found")
                    return Role.participant
                }
                logger.log(.error, "Role is unknown: \(role)")
                struct UnkownRoleError: Error {}
                throw UnkownRoleError()
                
            },
            googleLogin: {
                let credential = try await firebaseService.startGoogleSignInFlow()
                try await credential.linkOrSignInWithCredential()
            },
            appleLogin: {
                let credential = try await firebaseService.startSignInWithAppleFlow()
                try await credential.linkOrSignInWithCredential()
            },
            logout: {
                try Auth.auth().signOut()
            },
            userStateChanged: {
                
                let stream = await stateStream.stream()
                
                _ = Auth.auth().addStateDidChangeListener { auth, optionalUser in
                    
                    let userState: UserState = {
                        guard let user = optionalUser.optional else { return .loggedOut }
                        return user.isAnonymous ? .anonymous : .authenticated
                    }()
                    Task { [stateStream] in
                        await stateStream.yield(userState)
                    }
                }
                
                return stream
            }
        )
    }
}

extension AuthCredential {
    func linkOrSignInWithCredential () async throws {
        guard let currentUser = Auth.auth().currentUser else {
            _ = try await Auth.auth().signIn(with: self)
            return
        }
        do {
            if currentUser.isAnonymous {
                try await currentUser.link(with: self)
            } else {
                try Auth.auth().signOut()
                _ = try await Auth.auth().signIn(with: self)
            }
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.credentialAlreadyInUse.rawValue:
                _ = try await Auth.auth().signIn(with: self)
            default:
                throw error
            }
        }
    }
}
