import Model
import SwiftUI
import ComposableArchitecture

@Reducer
public struct DeleteConfirmation {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared var session: Session
        var eventId: UUID
        var deleteEventInFlight: Bool
        var showSuccessOverlay: Bool
        public init(
            destination: Destination.State? = nil,
            session: Shared<Session>,
            eventId: UUID,
            deleteEventInFlight: Bool = false,
            showSuccessOverlay: Bool = false
        ) {
            self.destination = destination
            self._session = session
            self.eventId = eventId
            self.deleteEventInFlight = deleteEventInFlight
            self.showSuccessOverlay = showSuccessOverlay
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case deleteButtonTap
        case cancelButtonTap
        case eventDeletedResponse
        case delegate(Delegate)
        public enum Delegate {
            case dismissEventDetail
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding:
                return .none
                
            case .presentError(let error):
                state.deleteEventInFlight = false
                state.destination = .alert(
                    .init(error: error)
                )
                return .none
                
            case .destination:
                return .none
                
            case .deleteButtonTap:
                state.deleteEventInFlight = true
                return .run { [eventId = state.eventId] send in
                    do {
                        try await apiClient.deleteEvent(eventId)
                        await send(.eventDeletedResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .cancelButtonTap:
                return .run { _ in
                    await dismiss()
                }
                
            case .eventDeletedResponse:
                state.deleteEventInFlight = false
                state.showSuccessOverlay = true
                return .run { send in
                    await send(.delegate(.dismissEventDetail))
                }
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
