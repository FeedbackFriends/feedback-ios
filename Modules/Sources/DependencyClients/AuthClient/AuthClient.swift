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
public struct AuthClient: Sendable {
    public var setupStateListener: @Sendable () async -> ()
    public var signInAnonymously: @Sendable () async throws -> ()
    public var fetchCustomRole: @Sendable () async throws -> Role?
    public var googleLogin: @Sendable () async throws -> ()
    public var appleLogin: @Sendable () async throws -> ()
    public var logout: @Sendable () async throws -> ()
    public var userStateChanged: @Sendable () async -> AsyncStream<UserState> = { .never }
}

public enum UserState: Sendable {
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

