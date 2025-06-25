import Foundation
import Model
import DesignSystem
import FeedbackFlowFeature
import ComposableArchitecture
import SwiftUI

@Reducer
public struct InitialiseFeedback {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case feedbackFeature(FeedbackFlow)
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: Destination.State?
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case startFeedback(pinCode: PinCode)
        case startFeedbackSessionResponse(FeedbackSession)
        case presentError(Error)
        case delegate(Delegate)
        public enum Delegate {
            case stopLoading
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding:
                return .none
                
            case .startFeedback(let pinCode):
                return .run { send in
                    do {
                        let feedbackSession = try await apiClient.startFeedbackSession(pinCode)
                        await send(.startFeedbackSessionResponse(feedbackSession))
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .destination:
                return .none
                
            case .startFeedbackSessionResponse(let feedbackSession):
                state.destination = .feedbackFeature(
                    FeedbackFlow.State.initialState(feedbackSession: feedbackSession)
                )
                return .send(.delegate(.stopLoading))
                
            case .presentError(let error):
                state.destination = .alert(
                    .init(error: error)
                )
                return .send(.delegate(.stopLoading))
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
