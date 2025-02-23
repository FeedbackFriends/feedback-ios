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
public struct AuthClient {
    public var setupStateListener: () -> ()
    public var signInAnonymously: @Sendable () async throws -> ()
    public var fetchCustomRole: @Sendable () async throws -> Role?
    public var googleLogin: @Sendable () async throws -> ()
    public var appleLogin: @Sendable () async throws -> ()
    public var logout: @Sendable () throws -> ()
    public var userStateChanged: () -> AsyncStream<UserState> = { .never }
}

public enum UserState {
    case authenticated, anonymous, loggedOut
}

public enum AuthenticationError: Error {
    case notSignedIn, couldNotFindWindow, couldNotFindClientID
}

public extension AuthClient {
    enum CustomError: Error {
        case loginCancelled
    }
}

