@testable import Tabbar
@testable import FeedbackFlow
import ComposableArchitecture
import Testing
import Foundation
import Model

@MainActor
struct InitialiseFeedbackTests {
    
    let session = FeedbackSession.init(
        title: "Hello",
        agenda: nil,
        questions: [
            .init(
                id: UUID(),
                questionText: "Hello",
                feedbackType: .emoji
            )
        ],
        ownerInfo: .init(
            name: nil,
            email: nil,
            phoneNumber: nil
        ),
        pinCode: .init(value: "1234"),
        date: Date()
    )
    
    @Test
    func testStartFeedbackSuccessNavigatesToFeedbackFlow() async {
        let store = TestStore(initialState: InitialiseFeedback.State()) {
            InitialiseFeedback()
        } withDependencies: {
            $0.apiClient.startFeedbackSession = { _ in session }
        }
        store.exhaustivity = .off

        await store.send(.startFeedback(pinCode: session.pinCode))
        await store.receive(\.startFeedbackSessionResponse) {
            guard case let .feedbackFeature(flowState) = $0.destination else {
                XCTFail("Expected .feedbackFeature")
                return
            }
            
            #expect(flowState.feedbackSession == session)
            #expect(flowState.submitFeedbackInFlight == false)
            #expect(flowState.presentSuccessOverlay == false)
            #expect(flowState.commentTextfieldFocused == false)
            #expect(flowState.questions.count == session.questions.count)
            #expect(flowState.path.count == 1)
        }
        await store.receive(\.delegate, .stopLoading)
    }

    @Test
    func testStartFeedbackFailureShowsAlertAndStopsLoading() async {
        let error = URLError(.cannotFindHost)
        let store = TestStore(initialState: InitialiseFeedback.State()) {
            InitialiseFeedback()
        } withDependencies: {
            $0.apiClient.startFeedbackSession = { _ in throw error }
        }

        await store.send(.startFeedback(pinCode: PinCode(value: "1234")))
        await store.receive(\.presentError) {
            $0.destination = .alert(.init(error: error))
        }
        await store.receive(\.delegate, .stopLoading)
    }
}
