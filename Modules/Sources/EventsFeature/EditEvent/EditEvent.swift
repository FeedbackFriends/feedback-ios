import Helpers
import ComposableArchitecture
import DesignSystem
import SwiftUI
import Helpers
import Helpers

@Reducer
public struct EditEvent {
   
    @ObservableState
    public struct State: Equatable {
        
        var eventInput: EventInput
        var eventId: UUID
        var createEventRequestInFlight = false
        var editRequestInFlight = false
        var showSuccessOverlay: Bool = false
        @Shared var session: Session
        
        @Presents var alert: AlertState<Never>?
        
        var editEventButtonDisabled: Bool {
            eventInput.title.isEmpty || eventInput.questions.isEmpty || editRequestInFlight || showSuccessOverlay
        }
        var recentlyUsedQuestions: Set<RecentlyUsedQuestions> {
            if let managerData = session.managerData {
                return managerData.recentlyUsedQuestions
            }
            return []
        }
        public init(
            eventInput: EventInput,
            eventId: UUID,
            session: Shared<Session>
        ) {
            self.eventInput = eventInput
            self.eventId = eventId
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case editEventButtonTap
        case presentError(Error)
        case editEventResponse
        case cancelButtonTap
        case alert(PresentationAction<Never>)
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .editEventButtonTap:
                state.editRequestInFlight = true
                return .run { [state = state] send in
                    do {
                        let _ = try await apiClient.updateEvent(
                            state.eventInput,
                            state.eventId
                        )
                        await send(.editEventResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .presentError(let error):
                state.editRequestInFlight = false
                state.alert = .init(error: error)
                return .none
                
            case .editEventResponse:
                state.editRequestInFlight = false
                state.showSuccessOverlay = true
                return .none
                
            case .binding:
                return .none
                
            case .cancelButtonTap:
                return .run { send in
                    await self.dismiss()
                }
                
            case .alert:
                return .none
            }
        }
    }
}
