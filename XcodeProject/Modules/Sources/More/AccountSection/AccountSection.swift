import ComposableArchitecture
import Helpers
import Logger
import SwiftUI

@Reducer
public struct AccountSection {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case modifyAccount(ModifyAccount)
        case changeUserType(ChangeUserType)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: Destination.State?
        @Shared var session: Session
        var accountInfo: AccountInfo {
            session.accountInfo
        }
        public init(session: Shared<Session>) {
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case updateProfileButtonTap
        case changeUserTypeButtonTap
    }
    
    public init() {}
    
    @Dependency(\.openURL) var openURL
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.logClient) var logger
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
            action in
            switch action {
            case .changeUserTypeButtonTap:
                guard let role = state.session.role else {
                    logger.log(.fault, "Change user button tap - Role in session is nil, should never happen")
                    return .none
                }
                state.destination = .changeUserType(.init(selectedUserType: role))
                return .none
                
            case .updateProfileButtonTap:
                state.destination = .modifyAccount(
                    .init(
                        nameInput: state.session.accountInfo.name ?? "",
                        emailInput: state.session.accountInfo.email ?? "",
                        phoneNumberInput: state.session.accountInfo.phoneNumber ?? ""
                    )
                )
                return .none
                
            case .binding:
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
