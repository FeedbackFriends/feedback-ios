import ComposableArchitecture
import OpenAPIRuntime
import Foundation
import OpenAPIURLSession
import Helpers

@DependencyClient
public struct APIClient {
    public var deleteAccount: () async throws -> ()
    public var _updateAccount: (
        _ name: String,
        _ email: String,
        _ phoneNumber: String
    ) async throws -> ()
    public var updateFcmToken: (String?) async throws -> ()
    public var getSession: () async throws -> Session
    public var startFeedbackSession: (_ pinCode: String) async throws -> FeedbackSession
    var _sendFeedback: (_ feedback: [Feedback], _ pinCode: String) async throws -> Bool
    public var createEvent: (EventInput) async throws -> ManagerEvent
    public var updateEvent: (_ input: EventInput, _ id: UUID) async throws -> ManagerEvent
    public var deleteEvent: (UUID) async throws -> ()
    public var createAccount: (Role?) async throws -> Session
    public var sessionChangedListener: () -> AsyncStream<Session> = { .never }
    public var joinEvent: (_ eventCode: String) async throws -> ()
    public var resetNewFeedbackForEvent: (_ eventId: UUID) async throws -> ()
    public var updateAccountRole: (_ role: Role) async throws -> ()
    public var getMockToken: () async throws -> (String)
}

public extension APIClient {
    
    func sendFeedback(feedback: [Feedback], pinCode: String) async throws -> Bool {
        try await _sendFeedback(feedback: feedback, pinCode: pinCode)
    }
    
    func updateAccount(name: String, email: String, phoneNumber: String) async throws {
        try await _updateAccount(name, email, phoneNumber)
    }
}

public extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

extension APIClient: TestDependencyKey {
    public static var previewValue = APIClient.mock
    public static let testValue = APIClient.mock
}

