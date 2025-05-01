import Helpers
import Combine
import DesignSystem
import SwiftUI
import ComposableArchitecture

@Reducer
public struct FeedbackFlow {
    
    public init() {}
    
    @Reducer
    public enum Path {
        case emoji(EmojiFeedback)
        case screenB(ScreenB)
        case screenC(ScreenC)
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        @ReducerCaseIgnored
        case showEventInfo
        @ReducerCaseIgnored
        case ratingPrompt
    }
    
    @ObservableState
    public struct State: Equatable {
        
        @Presents var destination: Destination.State?
        var path: StackState<Path.State>
        var submitFeedbackInFlight: Bool
        var presentSuccessOverlay: Bool
        var feedbackItemCompleted: Bool {
            switch path[questionIndex] {
                
            case .emoji(let emojiFeedback):
                emojiFeedback.feedbackCompleted
                
            case .screenB(_):
                fatalError("Not implemented")
                
            case .screenC(_):
                fatalError("Not implemented")
            }
        }
        var questions: IdentifiedArrayOf<Path.State>
        var date: Date {
            feedbackSession.date
        }
        let feedbackSession: FeedbackSession
        var commentTextfieldFocused: Bool
        var title: String {
            feedbackSession.title
        }
        var agenda: String? {
            feedbackSession.agenda
        }
        var ownerInfo: OwnerInfo {
            feedbackSession.ownerInfo
        }
        var questionText: String {
            questions[questionIndex].questionText
        }
        var questionIndex: Int {
            path.count - 1
        }
        var pinCode: PinCode {
            feedbackSession.pinCode
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case infoButtonTap
        case cancelButtonTap
        case presentError(Error)
        case sendFeedbackResponse(shouldPresentRatingPrompt: Bool)
        case previousQuestionButtonTap
        case nextQuestionButtonTap
        case submitButtonTap
        case destination(PresentationAction<Destination.Action>)
        case presentRatingPrompt
        case ratingPromptDismissed
        case navigateToNextQuestion
        case navigateToPreviousQuestion
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce {
            state,
            action in
            switch action {
                
            case .ratingPromptDismissed:
                return .run { send in
                    try await self.clock.sleep(for: .seconds(1))
                    await self.dismiss()
                }
                
            case .destination:
                return .none
                
            case .path(let pathAction):
                switch pathAction {
                case .element(id: _, action: .emoji(.delegate(.setCommentTextfieldFocus(let commentTextfieldFocused)))):
                    state.commentTextfieldFocused = commentTextfieldFocused
                    return .none
                default:
                    return .none
                }
                
            case .infoButtonTap:
                state.destination = .showEventInfo
                return .none

            case .cancelButtonTap:
                return .run { [dismiss] _ in await dismiss() }

            case .presentError(let error):
                state.submitFeedbackInFlight = false
                state.destination = .alert(.init(error: error))
                return .none
                
            case .sendFeedbackResponse(let shouldPrompt):
                state.presentSuccessOverlay = true
                state.submitFeedbackInFlight = false
                return .run { send in
                    try await self.clock.sleep(for: .seconds(2))
                    if shouldPrompt {
                        await send(.presentRatingPrompt)
                    } else {
                        await self.dismiss()
                    }
                }
                
            case .previousQuestionButtonTap:
                guard state.path.count > 0 else { return .none }
                guard !state.commentTextfieldFocused else {
                    state.commentTextfieldFocused = false
                    return .run { send in
                        try await self.clock.sleep(for: .seconds(0.5))
                        await send(.navigateToPreviousQuestion)
                    }
                }
                return .send(.navigateToPreviousQuestion)
                
                
            case .nextQuestionButtonTap:
                guard state.path.count < state.questions.count else { return .none }
                guard !state.commentTextfieldFocused else {
                    state.commentTextfieldFocused = false
                    return .run { send in
                        try await self.clock.sleep(for: .seconds(0.5))
                        await send(.navigateToNextQuestion)
                    }
                }
                return .send(.navigateToNextQuestion)
                
            case .submitButtonTap:
                state.commentTextfieldFocused = false
                state.submitFeedbackInFlight = true
                return .run { [state = state] send in
                    do {
                        let shouldPresentRatingPrompt = try await apiClient.sendFeedback(
                            feedback: state.path.map { .init($0) },
                            pinCode: state.pinCode
                        )
                        await send(.sendFeedbackResponse(shouldPresentRatingPrompt: shouldPresentRatingPrompt))
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .binding:
                return .none
                
            case .presentRatingPrompt:
                state.destination = .ratingPrompt
                return .none
                
            case .navigateToNextQuestion:
                if let next = state.questions[safe: state.questionIndex + 1] {
                    state.path.append(next)
                }
                return .none
                
            case .navigateToPreviousQuestion:
                if state.path.count > 1 {
                    let poppedElement = state.path.popLast()
                    if let poppedElement {
                        state.questions.updateOrAppend(poppedElement)
                    }
                }
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension FeedbackFlow.State {
    public static func initialState(feedbackSession: FeedbackSession) -> Self {
        guard let firstQuestion = feedbackSession.questions.first else {
            fatalError("There should be atleast one question in a feedback session")
        }
        return .init(
            path: StackState<FeedbackFlow.Path.State>.init([.init(firstQuestion)]),
            submitFeedbackInFlight: false,
            presentSuccessOverlay: false,
            questions: .init(uniqueElements: feedbackSession.questions.map { .init($0) }),
            feedbackSession: feedbackSession,
            commentTextfieldFocused: false
        )
    }
}

extension FeedbackFlow.Path.State: Equatable {}

extension FeedbackFlow.Path.State: Identifiable {
    
    init(_ question: ParticipantQuestion) {
        switch question.feedbackType {
            
        case .emoji:
            self = .emoji(
                .init(
                    questionId: question.id,
                    questionText: question.questionText
                )
            )
        case .comment:
            fatalError("Not implemented")
        case .thumpsUpThumpsDown:
            fatalError("Not implemented")
        case .opinion:
            fatalError("Not implemented")
        case .oneToTen:
            fatalError("Not implemented")
        }
    }
    
    public var id: UUID {
        questionId
    }
    var questionId: UUID {
        switch self {
        case .emoji(let state):
            state.questionId
        case .screenB(_):
            fatalError("Not implemented")
        case .screenC(_):
            fatalError("Not implemented")
        }
    }
    var questionText: String {
        switch self {
        case .emoji(let state):
            state.questionText
        case .screenB(_):
            fatalError("Not implemented")
        case .screenC(_):
            fatalError("Not implemented")
        }
    }
}

extension FeedbackInput {
    init(_ input: FeedbackFlow.Path.State) {
        switch input {
            
        case .emoji(let emojiFeedback):
            self = .init(
                type: .emoji(
                    emoji: emojiFeedback.selectedEmoji!,
                    comment: emojiFeedback.commentTextField.nilIfEmpty
                ),
                    questionId: input.questionId
                )
        case .screenB(_):
            fatalError("Not implemented")
        case .screenC(_):
            fatalError("Not implemented")
        }
    }
}
