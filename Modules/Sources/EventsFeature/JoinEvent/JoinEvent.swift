import ComposableArchitecture
import DesignSystem

@Reducer
public struct JoinEvent {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        var inputCode: String
        var enterCodeKeyboardIsFocused = false
        var showSuccessOverlay = false
        var joinRequestInFlight = false
        var disableJoinButton: Bool {
            if !PinCodeValidator.isValidPinCode(inputCode) || joinRequestInFlight || showSuccessOverlay {
                return true
            }
            return false
        }
        public init(inputCode: String = "") {
            self.inputCode = inputCode
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case closeButtonTap
        case joinButtonTap
        case joinSuccess
    }
    
    
    public init() {}
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.apiClient) var apiClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding:
                return .none
                
            case .presentError(let error):
                state.joinRequestInFlight = false
                state.destination = .alert(
                    AlertState(
                        title: { TextState("Noget gik galt")
                        },
                        message: { TextState(error.localizedDescription) }
                    )
                )
                return .none
                
            case .destination:
                return .none
                
            case .closeButtonTap:
                return .run { _ in
                    await dismiss()
                }
                
            case .joinButtonTap:
                state.joinRequestInFlight = true
                return .run { [eventCode = state.inputCode] send in
                    do {
                        _ = try await apiClient.joinEvent(eventCode: eventCode)
                        await send(.joinSuccess)
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .joinSuccess:
                state.joinRequestInFlight = false
                state.showSuccessOverlay = true
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

