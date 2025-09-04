import Model
import ComposableArchitecture
import DesignSystem
import SwiftUI

@Reducer
public struct EditEvent: Sendable {
   
    @ObservableState
    public struct State: Equatable, Sendable {
        
        var eventInput: EventInput
        var eventId: UUID
        var createEventRequestInFlight = false
        var editRequestInFlight = false
        var showSuccessOverlay: Bool = false
        
        @Presents var alert: AlertState<Never>?
		
		var editEventButtonDisabled: Bool {
			eventInput.title.isEmpty || eventInput.questions.isEmpty || editRequestInFlight || showSuccessOverlay
		}
		let recentlyUsedQuestions: Set<RecentlyUsedQuestions>
		public init(
			eventInput: EventInput,
			eventId: UUID,
			recentlyUsedQuestions: Set<RecentlyUsedQuestions>
		) {
			self.eventInput = eventInput
			self.eventId = eventId
			self.recentlyUsedQuestions = recentlyUsedQuestions
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
                        _ = try await apiClient.updateEvent(
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
                return .run { _ in
                    await self.dismiss()
                }
                
            case .alert:
                return .none
            }
        }
    }
}
