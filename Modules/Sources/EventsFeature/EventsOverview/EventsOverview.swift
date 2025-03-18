import Helpers
import ComposableArchitecture
import Foundation
import DesignSystem
import SwiftUI
import Helpers
import Logger

@Reducer
public struct EventsOverview {
    
    @Reducer
    public enum Destination {
        case createEvent(CreateEvent)
        case eventDetail(EventDetailFeature)
        case alert(AlertState<AlertAction>)
        case joinEvent(JoinEvent)
        @ReducerCaseIgnored
        case info(ParticipantEvent)
        @ReducerCaseIgnored
        case startFeedbackConfirmation(String)
        public enum AlertAction {
            case confirmedToCreateUser
        }
    }
    
    @ObservableState
    public struct State {
        var segmentedControl: SegmentedControlMenu
        @Presents public var destination: Destination.State? = nil
        @Shared var session: Session
        var searchTextfield: String = ""
        var filterCollection: FilterCollection = .init(
            allEnabled: true,
            todayEnabled: false,
            comingUpEnabled: false,
            previousEnabled: false
        )
        public var startFeedbackPincodeInFlight: String?
        public var attendingEventsScrollPosition: UUID?
        public init(
            destination: Destination.State? = nil,
            session: Shared<Session>,
            segmentedControl: SegmentedControlMenu = .yourMeetings
        ) {
            self.destination = destination
            self._session = session
            self.segmentedControl = segmentedControl
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case createEventButtonTap
        case managerEventTap(ManagerEvent)
        case joinEventButtonTap
        case startFeedbackButtonTap(pinCode: String)
        case delegate(Delegate)
        case infoButtonTap(ParticipantEvent)
        case confirmedToStartFeedback(pinCode: String)
        public enum Delegate {
            case startFeedback(pinCode: String)
            case navigateToSignUp
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.logClient) var logger
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .confirmedToStartFeedback(pinCode: let pinCode):
                return .send(.startFeedbackButtonTap(pinCode: pinCode))
                
            case .destination(.presented(.joinEvent(.delegate(.navigateToAttendingEvent(let pinCode))))):
                state.segmentedControl = .attending
                state.attendingEventsScrollPosition = state.session.participantEvents.first(where: { $0.pinCode == pinCode })?.id ?? nil
                state.destination = .startFeedbackConfirmation(pinCode)
                return .none
                
            case .onAppear:
                return .run  { send in
                    let _ = try await apiClient.getSession()
                }
                
            case .binding:
                return .none
                
            case .createEventButtonTap:
                
                if case .anonymoous = state.session.userType {
                    state.destination = .alert(
                        .init(
                            title: { TextState("Login påkrævet") },
                            actions: {
                                ButtonState(role: .cancel, label: { TextState("Ikke nu") })
                                ButtonState(action: .confirmedToCreateUser, label: { TextState("Opret bruger") })
                            },
                            message: { TextState("Opret bruger for at kunne tilgå dine egne events") })
                    )
                    return .none
                }
                state.destination = .createEvent(
                    CreateEvent.State(session: state.$session)
                )
                return .none
                
            case .managerEventTap(let event):
                state.destination = .eventDetail(
                    EventDetailFeature.State(
                        event: event,
                        session: state.$session
                    )
                )
                return .run { send in
                    do {
                        try await apiClient.resetNewFeedbackForEvent(event.id)
                    } catch {
                        logger.log(.error, "Reset new feedback failed with error: \(error.localizedDescription)")
                    }
                }
                
            case .destination(.presented(.createEvent(.delegate(.dismissAndNavigateToDetail(let event))))):
                state.destination = .eventDetail(
                    EventDetailFeature.State(
                        event: event,
                        session: state.$session,
                        destination: .invite(event)
                    )
                )
                return .none
                
            case .destination(.presented(.alert(let alertAction))):
                switch alertAction {
                case .confirmedToCreateUser:
                    return .send(.delegate(.navigateToSignUp))
                }
                
            case .destination:
                return .none
                
            case .joinEventButtonTap:
                state.destination = .joinEvent(.init())
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
