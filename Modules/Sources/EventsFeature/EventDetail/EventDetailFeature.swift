import DependencyClients
import Combine
import DesignSystem
import Foundation
import ComposableArchitecture
import Helpers
import APIClient
import UIKit

@Reducer
public struct EventDetailFeature {
    
    @Reducer
    public enum Destination {
        case deleteConfirmation(DeleteConfirmation)
        case editEvent(EditEvent)
        @ReducerCaseEphemeral
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        @ReducerCaseIgnored
        case invite(ManagerEvent)
        public enum ConfirmationDialog {
            case edit
            case delete
            case invite
        }
    }
    
    
    @ObservableState
    public struct State {
        var event: ManagerEvent
        @Presents var destination: Destination.State?
        var fetchEventDetailInFlight = true
        var navigationTitle: String {
            event.title
        }
        @Shared var session: Session
        
        public init(event: ManagerEvent, session: Shared<Session>, destination: Destination.State? = nil) {
            self.event = event
            self._session = session
            self.destination = destination
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case moreButtonTapped
        case allCommentsButtonTapped
        case onAppear
        case retryButtonTap
        case refresh
    }
    
    public init() {}
    
    @Dependency(\.calendar) var calendar
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
            action in
            switch action {
                
            case .destination(.presented(.deleteConfirmation(.delegate(.dismissEventDetail)))):
                return .run { _ in
                    try await clock.sleep(for: .seconds(2.5))
                    await dismiss()
                }
                
            case .binding:
                return .none
                
            case .destination(.presented(.editEvent(.delegate(.updateEventDetail(let event))))):
                state.event = event
                return .none
           
            case .destination(.presented(.confirmationDialog(let confirmationDialogAction))):
                switch confirmationDialogAction {
                    
                case .edit:
                    state.destination = .editEvent(
                        EditEvent.State(
                            eventInput: EventInput(state.event),
                            eventId: state.event.id,
                            session: state.$session
                        )
                    )
                case .delete:
                    state.destination = .deleteConfirmation(.init(session: state.$session, eventId: state.event.id))
                case .invite:
                    state.destination = .invite(state.event)
                }
                return .none
                
            case .destination:
                return .none
                
            case .moreButtonTapped:
                state.destination = .confirmationDialog(
                    ConfirmationDialogState<Destination.ConfirmationDialog>.init(
                        titleVisibility: .hidden,
                        title: { TextState("") },
                        actions: {
                            if state.event.feedbackSummary == nil {
                                ButtonState(action: .send(.edit)) {
                                    TextState("Edit ✏️")
                                }
                            }
                            ButtonState(action: .send(.invite)) {
                                TextState("Invite 👥")
                            }
                            ButtonState(role: .destructive, action: .send(.delete)) {
                                TextState("Delete 🗑️")
                            }
                            ButtonState(role: .cancel) {
                                TextState("Cancel")
                            }
                        }
                    )
                )
                return .none
                
            case .allCommentsButtonTapped:
                return .none
                
            case .onAppear:
                return .none
                
            case .retryButtonTap:
                return .none
                
            case .refresh:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
