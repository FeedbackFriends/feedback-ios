@testable import FeedbackFlowFeature
import ComposableArchitecture
import Testing
import Foundation

@MainActor
struct EmojiFeedbackTests {
    
    @Test
    func tapEmojiSelectsEmojiAndFocusesCommentField() async {
        let questionId = UUID()
        let store = TestStore(
            initialState: EmojiFeedback.State(
                questionId: questionId,
                questionText: "How was your experience?"
            )
        ) {
            EmojiFeedback()
        }
        #expect(!store.state.feedbackCompleted)
        await store.send(.onSmileyTapped(.happy)) {
            $0.selectedEmoji = .happy
        }
        await store.receive(\.delegate, .setCommentTextfieldFocus(true))
        #expect(store.state.feedbackCompleted)
    }

    @Test
    func tapOutsideTextFieldClosesCommentField() async {
        let questionId = UUID()
        let store = TestStore(
            initialState: EmojiFeedback.State(
                questionId: questionId,
                questionText: "How was your experience?"
            )
        ) {
            EmojiFeedback()
        }

        await store.send(.onTapOutsideTextfield)
        await store.receive(\.delegate, .setCommentTextfieldFocus(false))
    }

    @Test
    func bindingCommentTextFieldUpdatesState() async {
        let questionId = UUID()
        let store = TestStore(
            initialState: EmojiFeedback.State(
                questionId: questionId,
                questionText: "How was your experience?"
            )
        ) {
            EmojiFeedback()
        }

        await store.send(\.binding.commentTextField, "Great!") {
            $0.commentTextField = "Great!"
        }
    }
}
