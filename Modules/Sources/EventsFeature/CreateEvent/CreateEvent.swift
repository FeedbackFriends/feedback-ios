import ComposableArchitecture
import Helpers
import DesignSystem
import Helpers
import Foundation
import Helpers

@Reducer
public struct CreateEvent {
    @ObservableState
    public struct State: Equatable {
        var createEventRequestInFlight = false
        var eventInput = EventInput()
        @Presents var alert: AlertState<Never>?
        @Shared var session: NewSession
        var showSuccessOverlay: Bool = false
        
        var createEventButtonDisabled: Bool {
            eventInput.title.isEmpty || eventInput.questions.isEmpty || createEventRequestInFlight || showSuccessOverlay
        }
        var recentlyUsedQuestions: Set<RecentlyUsedQuestions> {
            if let managerData = session.managerData {
                return managerData.recentlyUsedQuestions
            }
            return []
        }
        public init(
            session: Shared<NewSession>
        ) {
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case createEventButtonTap
        case cancelButtonTap
        case alert(PresentationAction<Never>)
        case createEventResponse(ManagerEvent)
        case presentError(Error)
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case dismissAndNavigateToDetail(ManagerEvent)
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
            action in
            switch action {
                
            case .createEventButtonTap:
                state.createEventRequestInFlight = true
                return .run {  [state = state] send in
                    do {
                        let event = try await apiClient.createEvent(state.eventInput)
                        await send(.createEventResponse(event))
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .cancelButtonTap:
                return .run { _ in
                    await dismiss()
                }
                
            case .alert:
                return .none
                
            case .binding:
                return .none
                
            case .createEventResponse(let event):
                state.createEventRequestInFlight = false
                state.showSuccessOverlay = true
                return .run { send in
                    try await clock.sleep(for: .seconds(2))
                    await send(.delegate(.dismissAndNavigateToDetail(event)))
                }
                
            case .presentError(let error):
                state.createEventRequestInFlight = false
                state.alert = .init(error: error)
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

