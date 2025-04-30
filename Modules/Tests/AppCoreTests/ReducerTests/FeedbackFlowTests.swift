//@testable import FeedbackFlow
//import Testing
//import ComposableArchitecture
//import Foundation
//import Helpers
//
//@MainActor
//struct FeedbackFlowTests {
//    
//    @Test
//    func infoButtonTap() async {
//        let store = TestStore(
//            initialState: FeedbackFlow.State(
//                feedbackSession: .mock,
//                index: 0,
//                feedbackItems: .init(
//                    arrayLiteral: .init(
//                        elementType: .trailing,
//                        question: "",
//                        count: 1,
//                        questionId: UUID(),
//                        index: 0
//                    )
//                )
//            )
//        ) {
//            FeedbackFlow()
//        }
//        await store.send(.infoButtonTap) {
//            $0.destination = .showEventInfo
//        }
//        await store.send(.destination(.dismiss)) {
//            $0.destination = nil
//        }
//    }
//    
//    @Test
//    func cancelButtonTapped() async {
//        let didDismiss = LockIsolated(false)
//        
//        let store = TestStore(initialState: FeedbackFlow.State(
//            feedbackSession: .mock,
//            index: 0
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
//        let store = TestStore(
//            initialState: FeedbackFlow.State(
//                feedbackSession: .init(
//                    title: "title",
//                    agenda: "agenda",
//                    questions: [
//                        .init(
//                            id: UUID(),
//                            questionText: "Hello world",
//                            feedbackType: .emoji
//                        )
//                    ],
//                    ownerInfo: .init(
//                        name: nil,
//                        email: nil,
//                        phoneNumber: nil
//                    ),
//                    pinCode: "1234",
//                    date: Date()
//                ),
//                index: 0
//            )
//        ) {
//            FeedbackFlow()
//        } withDependencies: {
//            $0.apiClient.sendFeedback = { _, _ in true }
//            $0.continuousClock = ImmediateClock()
//        }
//        await store.send(.feedbackItems(.element(id: 0, action: .onSmileyTapped(.happy)))) {
//            $0.feedbackItems[id: 0]?.selectedEmoji = .happy
//            $0.feedbackItems[id: 0]?.commentsTextFieldFocused = true
//        }
//        await store.receive(\.feedbackItems[id: 0].delegate, .updateReadyForSubmissionButton) {
//            $0.feedbackItems[id: 0]?.readyForSubmission = true
//        }
//        await store.send(.feedbackItems(.element(id: 0, action: .delegate(.submitFeedback)))) {
//            $0.feedbackItems[id: 0]?.submitFeedbackInFlight = true
//        }
//        
//        await store.receive(\.sendFeedbackResponse, true) {
//            $0.presentSuccessOverlay = true
//            $0.feedbackItems[id: 0]?.submitFeedbackInFlight = false
//        }
//        
//        await store.receive(\.delegate, .presentAppRatingPrompt)
//    }
//    
//    @Test
//    func submitFeedbackFailure() async {
//        struct Failure: Error, Equatable {}
//        
//        let store = TestStore(initialState: FeedbackFlow.State(
//            feedbackSession: .init(
//                title: "title",
//                agenda: "agenda",
//                questions: [
//                    .init(
//                        id: UUID(),
//                        questionText: "Hello world",
//                        feedbackType: .emoji
//                    )
//                ],
//                ownerInfo: .init(
//                    name: nil,
//                    email: nil,
//                    phoneNumber: nil
//                ),
//                pinCode: "1234",
//                date: Date()
//            ),
//            index: 0
//        )) {
//            FeedbackFlow()
//        } withDependencies: {
//            $0.apiClient.sendFeedback = { _, _ in throw Failure() }
//        }
//        await store.send(.feedbackItems(.element(id: 0, action: .onSmileyTapped(.happy)))) {
//            $0.feedbackItems[id: 0]?.selectedEmoji = .happy
//            $0.feedbackItems[id: 0]?.commentsTextFieldFocused = true
//        }
//        await store.receive(\.feedbackItems[id: 0].delegate, .updateReadyForSubmissionButton) {
//            $0.feedbackItems[id: 0]?.readyForSubmission = true
//        }
//        await store.send(.feedbackItems(.element(id: 0, action: .delegate(.submitFeedback)))) {
//            $0.feedbackItems[id: 0]?.submitFeedbackInFlight = true
//        }
//        
//        await store.receive(\.presentError) {
//            $0.feedbackItems[id: 0]?.submitFeedbackInFlight = false
//            $0.destination = .alert(.init(error: Failure()))
//        }
//    }
////    
////    @Test
////    func navigateToNextFeedbackItemEmoji() async {
////        let store = await TestStore(initialState: FeedbackFlow.State(
////            feedbackSession: .mock,
////            index: 0
////        )) {
////            FeedbackFlow()
////        }
////        
////        await store.send(.feedbackItems(.element(id: 0, action: .delegate(.navigateToIndex(1))))) {
////            $0.selectedFeedbackItemEmojiIndex = 1
////        }
////    }
////    
////    @Test
////    func navigateToPreviousFeedbackItemEmoji() async {
////        let store = await TestStore(initialState: FeedbackFlow.State(
////            feedbackSession: .mock,
////            index: 1
////        )) {
////            FeedbackFlow()
////        }
////        
////        await store.send(.feedbackItems(.element(id: 1, action: .delegate(.navigateToIndex(0))))) {
////            $0.selectedFeedbackItemEmojiIndex = 0
////        }
////    }
//}
