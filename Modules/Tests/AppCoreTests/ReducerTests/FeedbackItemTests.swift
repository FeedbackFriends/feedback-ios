//@testable import FeedbackFlow
//import Testing
//import ComposableArchitecture
//import Foundation
//import Helpers
//
//@MainActor
//struct FeedbackItemEmojiTests {
//    
//    @Test
//    func onSmileyTapped() async {
//        let store = TestStore(initialState: FeedbackItemEmoji.State(
//            elementType: .leading,
//            question: "How was your experience?",
//            selectedEmoji: nil,
//            commentsTextFieldFocused: false,
//            count: 0,
//            questionId: UUID(),
//            index: 0
//        )) {
//            FeedbackItemEmoji()
//        }
//        
//        let emoji = Emoji.happy
//        
//        await store.send(.onSmileyTapped(emoji)) {
//            $0.selectedEmoji = emoji
//            $0.commentsTextFieldFocused = true
//        }
//        
//        await store.receive(\.delegate, .updateReadyForSubmissionButton)
//    }
//    
//    @Test
//    func onNextButtonTapped() async {
//        let store = TestStore(initialState: FeedbackItemEmoji.State(
//            elementType: .leading,
//            question: "How was your experience?",
//            selectedEmoji: nil,
//            commentsTextFieldFocused: true,
//            count: 0,
//            questionId: UUID(),
//            index: 0
//        )) {
//            FeedbackItemEmoji()
//        } withDependencies: {
//            $0.continuousClock = ImmediateClock()
//        }
//        
//        await store.send(.onNextButtonTapped) {
//            $0.commentsTextFieldFocused = false
//        }
//        await store.receive(\.delegate, .navigateToIndex(1))
//    }
//    
//    @Test
//    func onPreviousButtonTapped() async {
//        let store = TestStore(initialState: FeedbackItemEmoji.State(
//            elementType: .leading,
//            question: "How was your experience?",
//            selectedEmoji: nil,
//            commentsTextFieldFocused: true,
//            count: 0,
//            questionId: UUID(),
//            index: 1
//        )) {
//            FeedbackItemEmoji()
//        } withDependencies: {
//            $0.continuousClock = ImmediateClock()
//        }
//        
//        await store.send(.onPreviousButtonTapped) {
//            $0.commentsTextFieldFocused = false
//        }
//        await store.receive(\.delegate, .navigateToIndex(0))
//    }
//    
//    @Test
//    func onSubmitFeedbackTapped() async {
//        let store = TestStore(initialState: FeedbackItemEmoji.State(
//            elementType: .leading,
//            question: "How was your experience?",
//            selectedEmoji: Emoji.happy,
//            count: 1,
//            questionId: UUID(),
//            index: 0
//        )) {
//            FeedbackItemEmoji()
//        }
//        
//        await store.send(.onSubmitFeedbackTapped) {
//            $0.commentsTextFieldFocused = false
//            $0.submitFeedbackRequestinFlight = true
//        }
//        
//        await store.receive(\.delegate, .submitFeedback)
//    }
//    
//    @Test
//    func onTapOutsideTextfield() async {
//        let store = TestStore(initialState: FeedbackItemEmoji.State(
//            elementType: .leading,
//            question: "How was your experience?",
//            selectedEmoji: nil,
//            commentsTextFieldFocused: false,
//            count: 0,
//            questionId: UUID(),
//            index: 0
//        )) {
//            FeedbackItemEmoji()
//        }
//        
//        await store.send(.onTapOutsideTextfield) {
//            $0.commentsTextFieldFocused = false
//        }
//    }
//}
