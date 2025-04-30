import ComposableArchitecture
import Helpers
import Foundation

@Reducer
public struct EmojiFeedback {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        let questionId: UUID
        let questionText: String
        var selectedEmoji: Emoji?
        var commentTextField: String
        var commentTextfieldFocused: Bool
        var feedbackCompleted: Bool {
            selectedEmoji != nil
        }
        public init(
            questionId: UUID,
            questionText: String,
            selectedEmoji: Emoji? = nil,
            commentTextField: String = "",
            commentTextfieldFocused: Bool = false
        ) {
            self.questionId = questionId
            self.questionText = questionText
            self.selectedEmoji = selectedEmoji
            self.commentTextField = commentTextField
            self.commentTextfieldFocused = commentTextfieldFocused
        }
    }
    
    public enum Action: BindableAction {
        case onSmileyTapped(Emoji)
        case binding(BindingAction<State>)
        case onTapOutsideTextfield
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .onTapOutsideTextfield:
                state.commentTextfieldFocused = false
                return .none
                
            case .binding:
                return .none
                
            case .onSmileyTapped(let rating):
                state.selectedEmoji = rating
                state.commentTextfieldFocused = true
                return .none
            }
        }
    }
}
