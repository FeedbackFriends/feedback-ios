import Foundation
import Logger
import ComposableArchitecture
import FirebaseAuth
import Helpers

private var cont: AsyncStream<UserState>.Continuation!

public extension AuthClient {
    
    static var live: Self  {
        @Dependency(\.logClient) var logger
        return Self.init(
            setupStateListener: {
                _ = Auth.auth().addStateDidChangeListener { auth, optionalUser in
                    guard let user = optionalUser.optional else {
                        /// User logged out
                        cont.yield(.loggedOut)
                        return
                    }
                    if user.isAnonymous {
                        /// User is anonymous
                        cont.yield(.anonymous)
                    } else {
                        /// User is authenticated
                        cont.yield(.authenticated)
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
            googleLogin: { @MainActor in
                let credential = try await FirebaseService().startGoogleSignInFlow()
                logger.log(.debug, "Google sign in credential: \(credential)")
                try await linkOrSignInWithCredential(credential)
            },
            appleLogin: { @MainActor in
                let credential = try await FirebaseService().startSignInWithAppleFlow()
                try await linkOrSignInWithCredential(credential)
            },
            logout: {
                try Auth.auth().signOut()
            },
            userStateChanged: {
                AsyncStream { continuation in
                    cont = continuation
                }
            }
        )
    }
}

private func linkOrSignInWithCredential(_ credential: AuthCredential) async throws {
    
    /// Trying to link anonymous account with apple account
    print("linkOrSignInWithCredential: start link")
    
    
    guard let currentUser = Auth.auth().currentUser else {
        _ = try await Auth.auth().signIn(with: credential)
        return
    }
    do {
        try await currentUser.link(with: credential)
    } catch let error as NSError {
        switch error.code {
        case AuthErrorCode.providerAlreadyLinked.rawValue:
            print("linkOrSignInWithCredential: Provider already linked")
            _ = try await Auth.auth().signIn(with: credential)
            
        case AuthErrorCode.credentialAlreadyInUse.rawValue:
            print("linkOrSignInWithCredential: Credential already in use")
            _ = try await Auth.auth().signIn(with: credential)
        default:
            print("linkOrSignInWithCredential: Unexpected error: \(error.localizedDescription)")
            throw error
        }
    }
    
}
