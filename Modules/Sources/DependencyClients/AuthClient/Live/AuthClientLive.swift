import Foundation
import Logger
import ComposableArchitecture
import FirebaseAuth
import Helpers

actor UserStateStream {
    private var continuation: AsyncStream<UserState>.Continuation?
    
    func yield(_ state: UserState) {
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
                _ = Auth.auth().addStateDidChangeListener { auth, optionalUser in
                    
                    let userState: UserState = {
                        guard let user = optionalUser.optional else { return .loggedOut }
                        return user.isAnonymous ? .anonymous : .authenticated
                    }()
                    Task { [stateStream] in
                        await stateStream.yield(userState)
                    }
                }
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
                
                if role == "Organizer" {
                    logger.log("🔥 Firebase user loggedin: Organizer role found")
                    return Role.organizer
                } else if role == "Participant" {
                    logger.log("🔥 Firebase user loggedin: Participant role found")
                    return Role.participant
                }
                
                fatalError("Should not land here")
            },
            googleLogin: {
                let credential = try await firebaseService.startGoogleSignInFlow()
                guard let currentUser = Auth.auth().currentUser, currentUser.isAnonymous else {
                    _ = try await Auth.auth().signIn(with: credential)
                    return
                }
                try await currentUser.link(with: credential)
                _ = try await Auth.auth().signIn(with: credential)
            },
            appleLogin: {
                let credential = try await firebaseService.startSignInWithAppleFlow()
                guard let currentUser = Auth.auth().currentUser, currentUser.isAnonymous else {
                    _ = try await Auth.auth().signIn(with: credential)
                    return
                }
                try await currentUser.link(with: credential)
                _ = try await Auth.auth().signIn(with: credential)
            },
            logout: {
                try Auth.auth().signOut()
            },
            userStateChanged: {
                await stateStream.stream()
            }
        )
    }
}
