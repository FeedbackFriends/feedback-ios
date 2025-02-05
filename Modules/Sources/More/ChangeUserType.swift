import APIClient
import SwiftUI
import ComposableArchitecture
import Helpers

@Reducer
public struct ChangeUserType {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        var selectedUserType: Claim?
        var isLoading = false
        public init(selectedUserType: Claim) {
            self.selectedUserType = selectedUserType
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case saveButtonTap
        case updateAccountClaimResponse
        case closeButtonTap
        case delegate(Delegate)
        public enum Delegate {
            case refreshSession
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
                state.isLoading = false
                state.destination = .alert(
                    AlertState(
                        title: { TextState("Noget gik galt") },
                        message: { TextState(error.localizedDescription) }
                    )
                )
                return .none
                
            case .destination:
                return .none
                
            case .saveButtonTap:
                guard let claim = state.selectedUserType else { return .none }
                state.isLoading = true
                return .run { send in
                    do {
                        try await apiClient.updateAccountClaim(claim)
                        await send(.updateAccountClaimResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .updateAccountClaimResponse:
                state.isLoading = false
                return .run { send in
                    await send(.delegate(.refreshSession))
                }
                
            case .delegate:
                return .none
                
            case .closeButtonTap:
                return .run { _ in
                        await dismiss()
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

