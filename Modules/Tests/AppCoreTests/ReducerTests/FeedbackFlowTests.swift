//@testable import FeedbackFlow
//import Testing
//import ComposableArchitecture
//import Foundation
//
//@MainActor
//struct FeedbackFlowTests {
//    
//    @Test
//    func infoButtonTap() async {
//        let store = await TestStore(initialState: FeedbackFlow.State(
//            feedbackSession: FeedbackSession.mock(),
//            selectedFeedbackItemIndex: 0
//        )) {
//            FeedbackFlow()
//        }
//        
//        await store.send(.infoButtonTap) {
//            $0.destination = .showEventInfo
//        }
//    }
//    
//    @Test
//    func cancelButtonTapped() async {
//        let didDismiss = LockIsolated(false)
//        
//        let store = await TestStore(initialState: FeedbackFlow.State(
//            feedbackSession: FeedbackSession.mock(),
//            selectedFeedbackItemIndex: 0
//        )) {
//            FeedbackFlow()
//        } withDependencies: {
//            $0.dismiss = .init({
//                didDismiss.setValue(true)
//            })
//        }
//        
//        #expect(!didDismiss.value)
//        
//        await store.send(.cancelButtonTapped)
//        
//        #expect(didDismiss.value)
//    }
//    
//    @Test
//    func submitFeedbackSuccess() async {
//        let store = await TestStore(initialState: FeedbackFlow.State(
//            feedbackSession: FeedbackSession.mock(),
//            selectedFeedbackItemIndex: 0
//        )) {
//            FeedbackFlow()
//        } withDependencies: {
//            $0.apiClient.sendFeedback = { _, _ in true }
//        }
//        
//        await store.send(.feedbackItems(.element(id: 0, action: .delegate(.submitFeedback)))) {
//            $0.feedbackItems[id: 0]?.submitFeedbackInFlight = true
//        }
//        
//        await store.receive(\.sendFeedbackResponse(shouldPresentRatingPrompt: true)) {
//            $0.presentSuccessOverlay = true
//            $0.feedbackItems[id: 0]?.submitFeedbackInFlight = false
//        }
//        
//        await store.receive(\.delegate(.presentAppRatingPrompt))
//    }
//    
//    @Test
//    func submitFeedbackFailure() async {
//        struct Failure: Error, Equatable {}
//        
//        let store = await TestStore(initialState: FeedbackFlow.State(
//            feedbackSession: FeedbackSession.mock(),
//            selectedFeedbackItemIndex: 0
//        )) {
//            FeedbackFlow()
//        } withDependencies: {
//            $0.apiClient.sendFeedback = { _, _ in throw Failure() }
//        }
//        
//        await store.send(.feedbackItems(.element(id: 0, action: .delegate(.submitFeedback)))) {
//            $0.feedbackItems[id: 0]?.submitFeedbackInFlight = true
//        }
//        
//        await store.receive(\.presentError(Failure())) {
//            $0.feedbackItems[id: 0]?.submitFeedbackInFlight = false
//            $0.destination = .alert(.init(error: Failure()))
//        }
//    }
//    
//    @Test
//    func navigateToNextFeedbackItem() async {
//        let store = await TestStore(initialState: FeedbackFlow.State(
//            feedbackSession: FeedbackSession.mock(),
//            selectedFeedbackItemIndex: 0
//        )) {
//            FeedbackFlow()
//        }
//        
//        await store.send(.feedbackItems(.element(id: 0, action: .delegate(.navigateToIndex(1))))) {
//            $0.selectedFeedbackItemIndex = 1
//        }
//    }
//    
//    @Test
//    func navigateToPreviousFeedbackItem() async {
//        let store = await TestStore(initialState: FeedbackFlow.State(
//            feedbackSession: FeedbackSession.mock(),
//            selectedFeedbackItemIndex: 1
//        )) {
//            FeedbackFlow()
//        }
//        
//        await store.send(.feedbackItems(.element(id: 1, action: .delegate(.navigateToIndex(0))))) {
//            $0.selectedFeedbackItemIndex = 0
//        }
//    }
//}
