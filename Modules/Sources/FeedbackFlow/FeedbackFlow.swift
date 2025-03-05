import Helpers
import Combine
import DesignSystem
import SwiftUI
import ComposableArchitecture
import Helpers
import Helpers
import Helpers

@Reducer
public struct FeedbackFlow {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        @ReducerCaseIgnored
        case showMeetingInfo
    }
    
    @ObservableState
    public struct State {
        var feedbackSession: FeedbackSession
        var selectedFeedbackItemIndex: Int
        var feedbackItems: IdentifiedArrayOf<FeedbackItem.State>
        @Presents var destination: Destination.State?
        var presentSuccessOverlay = false
        
        public init(
            feedbackSession: FeedbackSession,
            index: Int = 0
        ) {
            
            self.feedbackSession = feedbackSession
            self.selectedFeedbackItemIndex = 0
            
            var feedbackItems: IdentifiedArrayOf<FeedbackItem.State> = []
            let count = feedbackSession.questions.count
            
            for (index, element) in feedbackSession.questions.enumerated() {
                let type: ButtonPlacement = if count == 1 {
                    .trailing
                } else if index == 0 {
                    .leading
                } else if index == count-1 {
                    .trailing
                } else {
                    .center
                }
                feedbackItems.append(
                    .init(
                        elementType: type,
                        question: element.questionText,
                        count: count,
                        questionId: element.id,
                        index: index
                    )
                )
            }
            self.feedbackItems = feedbackItems
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case infoButtonTap
        case cancelButtonTapped
        case presentError(Error)
        case feedbackItems(IdentifiedActionOf<FeedbackItem>)
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        case sendFeedbackResponse(shouldPresentRatingPrompt: Bool)
        public enum Delegate: Equatable {
            case presentAppRatingPrompt
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
            action in
            
            switch action {
                
            case .binding(\.selectedFeedbackItemIndex):
                for feedbackItem in state.feedbackItems {
                    state.feedbackItems[id: feedbackItem.id]?.focusedField = nil
                }
                return .none
                
            case .binding:
                return .none
                
            case .feedbackItems(.element(id: _, action: .delegate(let delegateAction))):
                switch delegateAction {
                case .navigateToIndex(let index):
                        state.selectedFeedbackItemIndex = index
                case .submitFeedback:
                    state.feedbackItems[id: state.feedbackItems.last!.id]?.submitFeedbackInFlight = true
                    let feedback: [Feedback] = state.feedbackItems.map {
                        Feedback(
                            type: .emoji(emoji: $0.selectedEmoji!, comment: $0.commentTextField.nilIfEmpty),
                            questionId: $0.questionId,
                            isNew: true
                        )
                    }
                    return .run { [pinCode = state.feedbackSession.pinCode, apiClient] send in
                        do {
                            let shouldPresentRatingPrompt = try await apiClient.sendFeedback(
                                feedback: feedback,
                                pinCode: pinCode
                            )
                            await send(.sendFeedbackResponse(shouldPresentRatingPrompt: shouldPresentRatingPrompt))
                        } catch {
                            await send(.presentError(error))
                        }
                    }
                    
                case .updateReadyForSubmissionButton:
                    let readyForSubmission = state.feedbackItems.allSatisfy { $0.selectedEmoji != nil }
                    if let lastItemIndex = state.feedbackItems.last?.index {
                        state.feedbackItems[id: lastItemIndex]?.readyForSubmission = readyForSubmission
                    }
                }
                return .none
                
            case .infoButtonTap:
                state.destination = .showMeetingInfo
                return .none
                
            case .cancelButtonTapped:
                return .run { [dismiss] _ in
                    await dismiss()
                }
                
            case .presentError(let error):
                state.feedbackItems[id: state.feedbackItems.last!.id]!.submitFeedbackInFlight = false
                state.destination = .alert(.init(error: error))
                return .none
                
            case .feedbackItems:
                return .none
                
            case .destination:
                return .none
                
            case .delegate:
                return .none
                
            case .sendFeedbackResponse(shouldPresentRatingPrompt: let shouldPresentRatingPrompt):
                state.presentSuccessOverlay = true
                state.feedbackItems[id: state.feedbackItems.last!.id]?.submitFeedbackInFlight = false
                guard shouldPresentRatingPrompt else {
                    return .run { @MainActor [clock, dismiss] send in
                        try await clock.sleep(for: .seconds(2))
                        await dismiss()
                    }
                }
                return .run { @MainActor [clock] send in
                    try await clock.sleep(for: .seconds(2))
                    send(.delegate(.presentAppRatingPrompt))
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.feedbackItems, action: \.feedbackItems) {
            FeedbackItem()
        }
    }
}
