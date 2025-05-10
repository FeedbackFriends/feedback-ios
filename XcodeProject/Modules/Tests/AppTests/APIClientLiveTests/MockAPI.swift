@testable import Implementations
@testable import Model
import ComposableArchitecture
import OpenAPI


struct MockAPI: APIProtocol {
    
    // MARK: - Handlers for endpoints
    var markActivityAsSeenHandler: (Operations.MarkActivityAsSeen.Input) async throws -> Operations.MarkActivityAsSeen.Output = { _ in
        fatalError("MockAPI: markActivityAsSeen unimplemented")
    }
    var getUpdatedSessionHandler: (Operations.GetUpdatedSession.Input) async throws -> Operations.GetUpdatedSession.Output = { _ in
        fatalError("MockAPI: getUpdatedSession unimplemented")
    }
    var getSessionHandler: (Operations.GetSession.Input) async throws -> Operations.GetSession.Output = { _ in
        fatalError("MockAPI: getSession unimplemented")
    }
    var mockIdTokenHandler: (Operations.MockIdToken.Input) async throws -> Operations.MockIdToken.Output = { _ in
        fatalError("MockAPI: mockIdToken unimplemented")
    }
    var joinEventHandler: (Operations.JoinEvent.Input) async throws -> Operations.JoinEvent.Output = { _ in
        fatalError("MockAPI: joinEvent unimplemented")
    }
    var createEventHandler: (Operations.CreateEvent.Input) async throws -> Operations.CreateEvent.Output = { _ in
        fatalError("MockAPI: createEvent unimplemented")
    }
    var startFeedbackSessionHandler: (Operations.StartFeedbackSession.Input) async throws -> Operations.StartFeedbackSession.Output = { _ in
        fatalError("MockAPI: startFeedbackSession unimplemented")
    }
    var sendFeedbackHandler: (Operations.SendFeedback.Input) async throws -> Operations.SendFeedback.Output = { _ in
        fatalError("MockAPI: sendFeedback unimplemented")
    }
    var linkFCMTokenToAccountHandler: (Operations.LinkFCMTokenToAccount.Input) async throws -> Operations.LinkFCMTokenToAccount.Output = { _ in
        fatalError("MockAPI: linkFCMTokenToAccount unimplemented")
    }
    var updateRoleHandler: (Operations.UpdateRole.Input) async throws -> Operations.UpdateRole.Output = { _ in
        fatalError("MockAPI: updateRole unimplemented")
    }
    var deleteAccountHandler: (Operations.DeleteAccount.Input) async throws -> Operations.DeleteAccount.Output = { _ in
        fatalError("MockAPI: deleteAccount unimplemented")
    }
    var modifyAccountHandler: (Operations.ModifyAccount.Input) async throws -> Operations.ModifyAccount.Output = { _ in
        fatalError("MockAPI: modifyAccount unimplemented")
    }
    var createAccountHandler: (Operations.CreateAccount.Input) async throws -> Operations.CreateAccount.Output = { _ in
        fatalError("MockAPI: createAccount unimplemented")
    }
    var sendNotificationHandler: (Operations.SendNotification.Input) async throws -> Operations.SendNotification.Output = { _ in
        fatalError("MockAPI: sendNotification unimplemented")
    }
    var markEventAsSeenHandler: (Operations.MarkEventAsSeen.Input) async throws -> Operations.MarkEventAsSeen.Output = { _ in
        fatalError("MockAPI: markEventAsSeen unimplemented")
    }
    var deleteEventHandler: (Operations.DeleteEvent.Input) async throws -> Operations.DeleteEvent.Output = { _ in
        fatalError("MockAPI: deleteEvent unimplemented")
    }
    var updateEventHandler: (Operations.UpdateEvent.Input) async throws -> Operations.UpdateEvent.Output = { _ in
        fatalError("MockAPI: updateEvent unimplemented")
    }
    
    func logoutHandler(_ input: OpenAPI.Operations.Logout.Input) async throws -> OpenAPI.Operations.Logout.Output {
        fatalError("MockAPI: logout unimplemented")
    }
    
    // MARK: - APIProtocol conformance
    func markActivityAsSeen(_ input: Operations.MarkActivityAsSeen.Input) async throws -> Operations.MarkActivityAsSeen.Output {
        try await markActivityAsSeenHandler(input)
    }
    func getUpdatedSession(_ input: Operations.GetUpdatedSession.Input) async throws -> Operations.GetUpdatedSession.Output {
        try await getUpdatedSessionHandler(input)
    }
    func getSession(_ input: Operations.GetSession.Input) async throws -> Operations.GetSession.Output {
        try await getSessionHandler(input)
    }
    func mockIdToken(_ input: Operations.MockIdToken.Input) async throws -> Operations.MockIdToken.Output {
        try await mockIdTokenHandler(input)
    }
    func joinEvent(_ input: Operations.JoinEvent.Input) async throws -> Operations.JoinEvent.Output {
        try await joinEventHandler(input)
    }
    func createEvent(_ input: Operations.CreateEvent.Input) async throws -> Operations.CreateEvent.Output {
        try await createEventHandler(input)
    }
    func startFeedbackSession(_ input: Operations.StartFeedbackSession.Input) async throws -> Operations.StartFeedbackSession.Output {
        try await startFeedbackSessionHandler(input)
    }
    func sendFeedback(_ input: Operations.SendFeedback.Input) async throws -> Operations.SendFeedback.Output {
        try await sendFeedbackHandler(input)
    }
    func linkFCMTokenToAccount(_ input: Operations.LinkFCMTokenToAccount.Input) async throws -> Operations.LinkFCMTokenToAccount.Output {
        try await linkFCMTokenToAccountHandler(input)
    }
    func updateRole(_ input: Operations.UpdateRole.Input) async throws -> Operations.UpdateRole.Output {
        try await updateRoleHandler(input)
    }
    func deleteAccount(_ input: Operations.DeleteAccount.Input) async throws -> Operations.DeleteAccount.Output {
        try await deleteAccountHandler(input)
    }
    func modifyAccount(_ input: Operations.ModifyAccount.Input) async throws -> Operations.ModifyAccount.Output {
        try await modifyAccountHandler(input)
    }
    func createAccount(_ input: Operations.CreateAccount.Input) async throws -> Operations.CreateAccount.Output {
        try await createAccountHandler(input)
    }
    func sendNotification(_ input: Operations.SendNotification.Input) async throws -> Operations.SendNotification.Output {
        try await sendNotificationHandler(input)
    }
    func markEventAsSeen(_ input: Operations.MarkEventAsSeen.Input) async throws -> Operations.MarkEventAsSeen.Output {
        try await markEventAsSeenHandler(input)
    }
    func deleteEvent(_ input: Operations.DeleteEvent.Input) async throws -> Operations.DeleteEvent.Output {
        try await deleteEventHandler(input)
    }
    func updateEvent(_ input: Operations.UpdateEvent.Input) async throws -> Operations.UpdateEvent.Output {
        try await updateEventHandler(input)
    }
    func logout(_ input: Operations.Logout.Input) async throws -> Operations.Logout.Output {
        try await logoutHandler(input)
    }
}
