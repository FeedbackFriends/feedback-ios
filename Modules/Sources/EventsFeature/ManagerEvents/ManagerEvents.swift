import Helpers
import ComposableArchitecture
import Foundation
import DesignSystem
import SwiftUI
import Helpers
import Logger

@Reducer
public struct ManagerEvents {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case eventDetail(EventDetailFeature)
        @ReducerCaseIgnored
        case startFeedbackConfirmation(String)
    }
    
    @ObservableState
    public struct State: Equatable {
        
        @Presents public var destination: Destination.State? = nil
        @Shared var session: NewSession
        var segmentedControl: SegmentedControlMenu
        var participantEvents: ParticipantEvents.State
        var searchTextfield: String = ""
        var filterCollection: FilterCollection = .init(
            allEnabled: true,
            todayEnabled: false,
            comingUpEnabled: false,
            previousEnabled: false
        )
        public var startFeedbackPincodeInFlight: String?
        public init(
            destination: Destination.State? = nil,
            session: Shared<NewSession>,
            segmentedControl: SegmentedControlMenu = .yourEvents
        ) {
            self.destination = destination
            self._session = session
            self.segmentedControl = segmentedControl
            self.participantEvents = .init(session: session)
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case managerEventTap(ManagerEvent)
        case participantEvents(ParticipantEvents.Action)
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.logClient) var logger
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .participantEvents:
                return .none
                
            case .destination(.dismiss):
                if case .eventDetail(let eventDetailState) = state.destination {
                    let eventId = eventDetailState.event.id
                    return .run { send in
                        do {
                            try await apiClient.markEventAsSeen(eventId)
                        } catch {
                            logger.log("Mark event as seen failed: \(error.localizedDescription)")
                        }
                    }
                }
                return .none
            
                
            case .binding:
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
                        try await apiClient.markEventAsSeen(event.id)
                    } catch {
                        logger.log("Reset new feedback failed with error: \(error.localizedDescription)")
                    }
                }
            
                
            case .destination:
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
