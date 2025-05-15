@testable import Model
import Foundation
import Testing

@MainActor
struct PresentableErrorTests {
    @Test func presentableErrorUrlError() async throws {
        let urlError = URLError(.badURL)
        let presentableError = urlError.localized
        #expect(presentableError.title == "Something Went Wrong")
        #expect(presentableError.message == urlError.localizedDescription)
    }
    @Test func presentableErrorApiError() async throws {
        let apiError = ApiError(domainCode: .feedbackAlreadySubmitted)
        let presentableError = apiError.localized
        #expect(presentableError.title == "Error")
        #expect(presentableError.message == "Feedback already submitted for this event.")
    }
    
    @Test func presentableErrorGenericError() async throws {
        let genericError = NSError(domain: "TestDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "A generic error occurred."])
        let presentableError = genericError.localized
        #expect(presentableError.title == "Something Went Wrong")
        #expect(presentableError.message == "A generic error occurred.")
    }
    
    @Test func presentableErrorLoginFlowCancelled() async throws {
        let loginFlowCancelledError = LoginFlowCancelled()
        let presentableError = loginFlowCancelledError.localized
        #expect(presentableError.title == "Something Went Wrong")
        #expect(presentableError.message == "An unexpected issue occurred.")
    }
    
    @Test func presentableErrorApiErrorEventAlreadyJoined() async throws {
        let apiError = ApiError(domainCode: .eventAlreadyJoined)
        let presentableError = apiError.localized
        #expect(presentableError.title == "Error")
        #expect(presentableError.message == "You already joined this event.")
    }
}

extension ApiError {
    init (domainCode: DomainCode) {
        self.init(
            timestamp: nil,
            message: nil,
            domainCode: domainCode,
            exceptionType: nil,
            path: nil
        )
    }
}
