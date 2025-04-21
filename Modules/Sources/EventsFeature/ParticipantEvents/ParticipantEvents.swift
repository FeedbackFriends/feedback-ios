import ComposableArchitecture
import Helpers
import SwiftUI

@Reducer
public struct ParticipantEvents {
    
    @Reducer(state: .equatable)
    public enum Destination {
        @ReducerCaseIgnored
        case info(ParticipantEvent)
        @ReducerCaseIgnored
        case startFeedbackConfirmation(String)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: Destination.State?
        @Shared var session: NewSession
        public var startFeedbackPincodeInFlight:  String?
        public init(session: Shared<NewSession>) {
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case infoButtonTap(ParticipantEvent)
        case startFeedbackButtonTap(pinCode: String)
        case confirmedToStartFeedback(pinCode: String)
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case startFeedback(pinCode: String)
            case navigateToSignUp
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
            action in
            switch action {
                
            case .binding:
                return .none
                
            case .confirmedToStartFeedback(pinCode: let pinCode):
                return .send(.startFeedbackButtonTap(pinCode: pinCode))
                
            case .destination:
                return .none
                
            case .startFeedbackButtonTap(pinCode: let pinCode):
                state.startFeedbackPincodeInFlight = pinCode
                return .send(.delegate(.startFeedback(pinCode: pinCode)))
                
            case .delegate:
                return .none
                
            case .infoButtonTap(let event):
                state.destination = .info(event)
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
