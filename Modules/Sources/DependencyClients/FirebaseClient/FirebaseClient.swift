import Combine
import Foundation
import FirebaseCrashlytics
import Firebase
import FirebaseCore
import FirebaseAuth
import ComposableArchitecture
import Helpers
import Logger

@DependencyClient
public struct FirebaseClient {
    public var setup: @Sendable () async throws -> Void
    public var signInAnonymously: @Sendable () async throws -> ()
    public var fetchCustomClaim: @Sendable () async throws -> Claim?
    public var googleLogin: @Sendable () async throws -> Void
    public var appleLogin: @Sendable () async throws -> Void
    public var microsoftLogin: @Sendable () async throws -> String
    public var logout: @Sendable () throws -> Void
    public var userInfo: () -> (String?, String?) = { (nil, nil) }
    public var logNonFatalError: (
        _ error: Error,
        _ path: String,
        _ fileName: String,
        _ lineNumber: String,
        _ code: Int?
    ) -> Void
    public var sendAnalytics: @Sendable (AnalyticsData) -> Void
    public var userStateChanged: () -> AsyncStream<UserState> = { .never }
    public var getIDToken: @Sendable () async throws -> String?
    var _sendEmailLink: (_ email: String) async throws -> Void
    public func sendEmailLink(email: String) async throws -> Void {
        try await _sendEmailLink(email)
    }
    public var _signUpWithEmailLink: (
        _ email: String,
        _ link: String,
        _ claim: Claim
    ) async throws -> ()
    public func signUpWithEmailLink(
        email: String,
        link: String,
        claim: Claim
    ) async throws -> () {
        try await _signUpWithEmailLink(email, link, claim)
    }
}

public enum UserState {
    case authenticated, anonymous, loggedOut
}

public enum AuthenticationError: Error {
    case notSignedIn, couldNotFindWindow, couldNotFindClientID
}

private var cont: AsyncStream<UserState>.Continuation!

public extension FirebaseClient {
    
    static var live: Self  {
        @Dependency(\.logClient) var logger
        
        
        return Self.init(
            setup: {
                print("********** SETUP intialised")
                
                _ = try await Auth.auth().addStateDidChangeListener { auth, optionalUser in
                    print("****************** tokrn updated: \(optionalUser?.uid ?? "no user")")
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
            fetchCustomClaim: {
                guard let currentUser = Auth.auth().currentUser else {
                    throw AuthenticationError.notSignedIn
                }
                guard let claim = try await currentUser.getIDTokenResult().claims["custom_claims"] as? String else {
                    logger.log("🔥 Firebase user loggedin: Logged in user, but no custom claims found")
                    return nil
                }
                
                if claim == "Manager" {
                    logger.log("🔥 Firebase user loggedin: Manager claim found")
                    return .manager
                } else if claim == "Participant" {
                    logger.log("🔥 Firebase user loggedin: Participant claim found")
                    return .participant
                }
                
                fatalError("Should not land here")
            },
            googleLogin: { @MainActor in
                let credential = try await AuthService().startGoogleSignInFlow()
                logger.log(.debug, "Google sign in credential: \(credential)")
                try await linkOrSignInWithCredential(credential)
            },
            appleLogin: { @MainActor in
                let credential = try await AuthService().startSignInWithAppleFlow()
                try await linkOrSignInWithCredential(credential)
            },
            microsoftLogin: { @MainActor in
                fatalError()
            },
            logout: {
                try Auth.auth().signOut()
            },
            userInfo: {
                let email = Auth.auth().currentUser?.email
                let name = Auth.auth().currentUser?.displayName
                let phone = Auth.auth().currentUser?.phoneNumber
                let image = Auth.auth().currentUser?.photoURL
                
                return (email, name)
            },
            logNonFatalError: { error, path, fileName, lineNumber, code in
                
                let userInfo: [String: Any] = [
                    "Description": error.localizedDescription,
                    "File Name": fileName,
                    "Line Number": lineNumber,
                    "Path": path
                ]
                
                let NSError = NSError(domain: "\(type(of: error))", code: code ?? 0, userInfo: userInfo)
                Crashlytics.crashlytics().record(error: NSError)
            },
            sendAnalytics: { analyticsData in
                //            switch analyticsData {
                //            case let .event(name: name, properties: properties):
                ////              Firebase.Analytics.logEvent(name, parameters: properties)
                //
                //
                //            case .userId(let id):
                //              Firebase.Analytics.setUserID(id)
                //              Crashlytics.crashlytics().setUserID(id)
                //
                //            case let .userProperty(name: name, value: value):
                //              Firebase.Analytics.setUserProperty(value, forName: name)
                //
                //            case .screen(name: let name):
                ////              Firebase.Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                ////                AnalyticsParameterScreenName: name
                ////              ])
                //                return
                //
                //            case .error(let error):
                //              Crashlytics.crashlytics().record(error: error)
                //            }
                
            },
            userStateChanged: {
                AsyncStream { continuation in
                    cont = continuation
                }
            },
            getIDToken: { try await Auth.auth().currentUser?.getIDToken() },
            _sendEmailLink: { email in
                let actionCodeSettings = ActionCodeSettings()
                actionCodeSettings.url = URL(
                    string: "https://letsgrow.page.link/email-link-login"
                )
                actionCodeSettings.handleCodeInApp = true
                //            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
                
                try await Auth.auth().sendSignInLink(
                    toEmail: "nicolaidam96@gmail.com",
                    actionCodeSettings: actionCodeSettings
                )
            },
            _signUpWithEmailLink: { email, link, claim in
                fatalError()
//                let _ = try await Auth.auth().signIn(withEmail: email, link: link)
//                switch claim {
//                case .manager:
//                    cont.yield(UserState.login(.manager))
//                case .participant:
//                    cont.yield(UserState.login(.participant))
//                }
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


public extension FirebaseClient {
    enum CustomError: Error {
        case loginCancelled
    }
}

//public extension FirebaseClient {
//    static let mock = Self.init(
//        signInAnonymously: {
//            cont.yield(.login(nil))
//        },
//        userLoggedIn: { true },
//        googleLogin: { _ in
//            cont.yield(.login(.manager))
//        },
//        appleLogin: { _ in },
//        microsoftLogin: {_ in
//            fatalError()
//        },
//        logout: {
//            cont.yield(.logOut)
//        },
//        userInfo: {
//            return ("mock@email.com","Mock Mocksen")
//        },
//        logNonFatalError: { _, _, _, _, _  in },
//        sendAnalytics: { _ in },
//        userStateChanged: {
//            AsyncStream {
//                cont = $0
//            }
//        },
//        getIDToken: { "" },
//        _sendEmailLink: { sendEmailInput in
//            
//        },
//        _signUpWithEmailLink: { email, link, claim in
//        }
//    )
//}

public extension FirebaseClient {
    static let failing = Self()
}

