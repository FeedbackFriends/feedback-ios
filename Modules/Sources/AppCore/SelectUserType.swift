import SwiftUI
import ComposableArchitecture
import Helpers
import DesignSystem

@Reducer
public struct SelectUserType {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        var selectedUserType: Role?
        public init() {}
        var isLoading: Bool = false
        var disableUserTypeSelectionButton: Bool {
            selectedUserType == nil
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case createAccountButtonTap
        case createAccountResponse
        case rolesSuccessfullyFetchedForAuthenticatedUser(Role?)
        case delegate(Delegate)
        public enum Delegate {
            case getSession
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
            action in
            switch action {
                
            case .binding:
                return .none
                
            case .presentError(let error):
                state.isLoading = false
                state.destination = .alert(
                    .init(error: error)
                )
                return .none
                
            case .destination:
                return .none
                
            case .createAccountButtonTap:
                state.isLoading = true
                return .run { [role = state.selectedUserType] send in
                    do {
                        let _ = try await apiClient.createAccount(role)
                        await send(.createAccountResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }
            case .createAccountResponse:
                return .run  { send in
                    do {
                        let role = try await authClient.fetchCustomRole()
                        await send(.rolesSuccessfullyFetchedForAuthenticatedUser(role))
                        
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .rolesSuccessfullyFetchedForAuthenticatedUser(let role):
                state.isLoading = false
                return .send(.delegate(.getSession))
                
            case .delegate(_):
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

#Preview {
    SelectUserTypeView(
        store: .init(
            initialState: .init(),
            reducer: {
                SelectUserType()
            }
        )
    )
}

