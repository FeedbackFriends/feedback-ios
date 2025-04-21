import Helpers
import Combine
import ComposableArchitecture
import SwiftUI
import Helpers
import Helpers

public enum ButtonPlacement: Equatable {
    case leading, center, trailing
}
public enum ButtonType {
    case next
    case previous
    case submit
    case smiley
}

@Reducer
public struct FeedbackItem {
    @ObservableState
    public struct State: Identifiable, Equatable {
        public var id: Int { index }
        var elementType: ButtonPlacement
        var question: String
        var selectedEmoji: Emoji?
        var commentTextField: String = ""
        public var commentsTextFieldFocused: Bool = false
        var count: Int
        var submitFeedbackInFlight: Bool = false
        let questionId: UUID
        let index: Int
        var submitFeedbackRequestinFlight: Bool = false
        public var readyForSubmission: Bool = false
        var disableSendButton: Bool {
            submitFeedbackInFlight || !readyForSubmission
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onSmileyTapped(Emoji)
        case showKeyboard
        case onNextButtonTapped
        case onPreviousButtonTapped
        case onSubmitFeedbackTapped
        case onTapOutsideTextfield
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case navigateToIndex(Int)
            case submitFeedback
            case updateReadyForSubmissionButton
        }
    }
    
    public init() {}
    
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding:
                return .none
                
            case .onAppear:
                if !state.commentTextField.isEmpty {
                    state.commentsTextFieldFocused = false
                }
                return .none
                
            case .onSmileyTapped(let rating):
                state.selectedEmoji = rating
                state.commentsTextFieldFocused = true
                return .run { send in
                    await send(.delegate(.updateReadyForSubmissionButton))
                }
                
            case .showKeyboard:
                return .none
                
            case .onNextButtonTapped:
                let newIndex = state.index+1
                guard state.commentsTextFieldFocused else {
                    return .send(.delegate(.navigateToIndex(newIndex)))
                }
                state.commentsTextFieldFocused = false
                return .run { [clock] send in
                    try await clock.sleep(for: .seconds(0.6))
                    await send(.delegate(.navigateToIndex(newIndex)), animation: .default)
                }
                
            case .onPreviousButtonTapped:
                let newIndex = state.index-1
                guard state.commentsTextFieldFocused else {
                    return .send(.delegate(.navigateToIndex(newIndex)))
                }
                state.commentsTextFieldFocused = false
                return .run { [clock] send in
                    try await clock.sleep(for: .seconds(0.6))
                    await send(.delegate(.navigateToIndex(newIndex)), animation: .default)
                }
                
            case .onSubmitFeedbackTapped:
                state.commentsTextFieldFocused = false
                state.submitFeedbackRequestinFlight = true
                // Api call, error alert, and reset loading state happens in outer reducer
                return .send(.delegate(.submitFeedback))
                
            case .onTapOutsideTextfield:
                state.commentsTextFieldFocused = false
                return .none
                
            case .delegate:
                return .none
                
            }
        }
    }
}
