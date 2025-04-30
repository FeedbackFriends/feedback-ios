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
        let date: Date
        let feedbackSession: FeedbackSession
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
        var pinCode: String {
            feedbackSession.pinCode
        }
        
        public init(
            feedbackSession: FeedbackSession,
        ) {
            self.feedbackSession = feedbackSession
            self.submitFeedbackInFlight = false
            self.presentSuccessOverlay = false
            self.questions = .init(uniqueElements: feedbackSession.questions.map { .init($0) })
            guard let firstQuestion = feedbackSession.questions.first else {
                fatalError("There should be atleast one question in a feedback session")
            }
            self.path = StackState<Path.State>.init([.init(firstQuestion)])
//            self.feedbackItemCompleted = false
            self.date = feedbackSession.date
            
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
                
            case .path:
                return .none
                
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
                guard !state.path[state.questionIndex].textfieldFocused else {
                    hideKeyboard()
                    return .run { send in
                        try await self.clock.sleep(for: .seconds(0.5))
                        await send(.navigateToPreviousQuestion)
                    }
                }
                return .send(.navigateToPreviousQuestion)
                
                
            case .nextQuestionButtonTap:
                guard state.path.count < state.questions.count else { return .none }
                guard !state.path[state.questionIndex].textfieldFocused else {
                    hideKeyboard()
                    return .run { send in
                        try await self.clock.sleep(for: .seconds(0.5))
                        await send(.navigateToNextQuestion)
                    }
                }
                return .send(.navigateToNextQuestion)
                
            case .submitButtonTap:
                hideKeyboard()
                state.submitFeedbackInFlight = true
                return .run { [state = state] send in
                    do {
                        let shouldPresentRatingPrompt = try await apiClient.sendFeedback(
                            feedback: state.path.map {
                                switch $0 {
                                    
                                case .emoji(let emojiFeedback):
                                        .init(
                                            type: .emoji(emoji: emojiFeedback.selectedEmoji!, comment: emojiFeedback.commentTextField.nilIfEmpty),
                                            questionId: $0.questionId
                                        )
                                case .screenB(_):
                                    fatalError("Not implemented")
                                case .screenC(_):
                                    fatalError("Not implemented")
                                }
                            },
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
    var textfieldFocused: Bool {
        switch self {
        case .emoji(let state):
            state.commentTextfieldFocused
        case .screenB(_):
            fatalError("Not implemented")
        case .screenC(_):
            fatalError("Not implemented")
        }
    }
}
