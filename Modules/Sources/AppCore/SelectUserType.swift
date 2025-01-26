import SwiftUI
import ComposableArchitecture
import Helpers
import APIClient
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
        var selectedUserType: Claim?
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
        case claimsSuccessfullyFetchedForAuthenticatedUser(Claim?)
        case delegate(Delegate)
        public enum Delegate {
            case getSession
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.firebaseClient) var firebaseClient
    
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
                    AlertState(
                        title: { TextState("Noget gik galt")
                        },
                        message: { TextState(error.localizedDescription) }
                    )
                )
                return .none
                
            case .destination:
                return .none
                
            case .createAccountButtonTap:
                state.isLoading = true
                return .run { [claim = state.selectedUserType] send in
                    do {
                        let _ = try await apiClient.createAccount(claim)
                        await send(.createAccountResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }
            case .createAccountResponse:
                return .run  { send in
                    do {
                        let claim = try await firebaseClient.fetchCustomClaim()
                        await send(.claimsSuccessfullyFetchedForAuthenticatedUser(claim))
                        
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .claimsSuccessfullyFetchedForAuthenticatedUser(let claim):
                state.isLoading = false
                return .send(.delegate(.getSession))
                
            case .delegate(_):
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

public struct SelectUserTypeView: View {
    
    @Bindable var store: StoreOf<SelectUserType>
    
    public init(store: StoreOf<SelectUserType>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What would you like to use the app for?")
                .padding(.top, 30)
                .font(.montserratBold, 14)
                .foregroundColor(.themeDarkGray)
            UserTypePickerView(selectedUserType: $store.selectedUserType)
            Button {
                store.send(.createAccountButtonTap)
            } label: {
                Text("Create account")
            }
            .buttonStyle(LargeButtonStyle())
            .isLoading(store.isLoading)
            .disabled(store.disableUserTypeSelectionButton)
            .padding(.bottom, 16)
        }
        .padding(.all, Theme.padding)
        .background(Color.themeBackground)
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

