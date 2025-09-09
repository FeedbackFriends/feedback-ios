import Model
import DesignSystem
import Foundation
import ComposableArchitecture
import UIKit
import Utility

@Reducer
public struct EventDetailFeature: Sendable {
	
	@Reducer(state: .equatable, .sendable)
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
	public struct State: Equatable, Sendable {
		public var event: ManagerEvent
		@Presents var destination: Destination.State?
		var fetchEventDetailInFlight = true
		var navigationTitle: String {
			event.title
		}
		@Shared var session: Session
		var shareText: String {
		"""
		You’re invited to \(event.title)!   
		Use pin code \(event.pinCode?.value ?? "") to join.
		
		👇🏼 Tap the link to join:  
		\(inviteLink)
		"""
		}
		
		var inviteLink: String = ""
		
		public init(
			event: ManagerEvent,
			destination: Destination.State? = nil,
			fetchEventDetailInFlight: Bool = true,
			session: Shared<Session>
		) {
			self.event = event
			self.destination = destination
			self.fetchEventDetailInFlight = fetchEventDetailInFlight
			self._session = session
		}
	}
	
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case destination(PresentationAction<Destination.Action>)
		case moreButtonTapped
		case onTask
		case retryButtonTap
		case refresh
		case sessionUpdated(Session)
	}
	
	public init() {}
	
	@Dependency(\.calendar) var calendar
	@Dependency(\.dismiss) var dismiss
	@Dependency(\.continuousClock) var clock
	@Dependency(\.apiClient) var apiClient
	@Dependency(\.webURLClient) var webURLClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
				
			case .destination(.presented(.deleteConfirmation(.delegate(.dismissEventDetail)))):
                return .run { _ in
					try await clock.sleep(for: .seconds(2.5))
					await dismiss()
				}
				
			case .binding:
				return .none
				
			case .destination(.presented(.confirmationDialog(let confirmationDialogAction))):
				switch confirmationDialogAction {
					
				case .edit:
					let recentlyUsedQuestions = if let managerData = state.session.managerData {
						Set<RecentlyUsedQuestions>(managerData.recentlyUsedQuestions)
					} else {
						Set<RecentlyUsedQuestions>()
					}
					state.destination = .editEvent(
						EditEvent.State(
							eventInput: EventInput(state.event),
							eventId: state.event.id,
							recentlyUsedQuestions: recentlyUsedQuestions
						)
					)
				case .delete:
					state.destination = .deleteConfirmation(.init(eventId: state.event.id))
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
                            if state.event.feedbackSummary == nil && state.event.pinCode != nil {
                                ButtonState(action: .send(.edit)) {
                                    TextState("Edit ✏️")
                                }
                            }
                            if state.event.pinCode != nil {
                                ButtonState(action: .send(.invite)) {
                                    TextState("Invite 👥")
                                }
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
				
			case .onTask:
                if let pinCode = state.event.pinCode {
                    do {
                        state.inviteLink = try self.webURLClient.inviteUrl(pinCode: pinCode).absoluteString
                    } catch {
                        fatalError("Failed to generate invite URL: \(error)")
                    }
                }
				return .publisher {
					state.$session.publisher
						.map(Action.sessionUpdated)
				}
				
			case .sessionUpdated(let updatedSession):
				guard
					let managerData = updatedSession.managerData,
					let event = managerData.managerEvents[id: state.event.id]
				else {
					return .none
				}
				state.event = event
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
