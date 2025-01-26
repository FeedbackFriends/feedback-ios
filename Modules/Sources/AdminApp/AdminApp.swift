import APIClient
import ComposableArchitecture
import OpenAPIRuntime
import OpenAPIURLSession
import SwiftUI

@Reducer
public struct AdminApp {
    
    @ObservableState
    public struct State: Equatable {
        var users: IdentifiedArrayOf<UserType>? = nil
        var userDetail: UserType?
        var error: String?
        var selection: UserType.ID?
        var sortOrder: [KeyPathComparator<UserType>] = []
        var selectedUser: UserType? {
            guard let id = selection else { return nil }
            return users![id: id]
        }
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case listUsersResponse([UserType])
        case presentError(Error)
        case tryAgainButtonTap
        case deleteUserButtonTap(String)
        case onTapUser(UserType)
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                return .run { send in
                    do {
                        let users = try await apiClient.listUsers()
                        await send(.listUsersResponse(users))
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .tryAgainButtonTap:
                state.error = nil
                return .run { send in
                    do {
                        let users = try await apiClient.listUsers()
                        await send(.listUsersResponse(users))
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .listUsersResponse(let users):
                state.users = .init(uniqueElements: users)
                return .none
                
            case .presentError(let error):
                state.error = error.localizedDescription
                return .none
                
            case .deleteUserButtonTap:
                return .none
            
            case .onTapUser(let user):
                state.userDetail = user
                return .none
            
            case .binding:
                return .none
            }
        }
    }
}

extension UserType: Identifiable {
    public var id: String {
        self.uid!
    }
}

public struct AdminAppView: View {
    
    @Bindable var store: StoreOf<AdminApp>
    
    public init(store: StoreOf<AdminApp>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationSplitView {
            List {
                Text("Users")
            }
        } content: {
            if let error = store.error {
              Text("Error")
                Text(error)
                Button("Try again") {
                    store.send(.tryAgainButtonTap)
                }
            } else if let users = store.users {
                if users.isEmpty {
                    Text("Empty")
                } else {
                    
                    Table(users, selection: $store.selection, sortOrder: $store.sortOrder) {
                        TableColumn("Email") { user in
                            Text(user.email ?? "")
                        }
                        TableColumn("DisplayName") { user in
                            Text(user.displayName ?? "")
                        }
                        TableColumn("PhoneNumber") { user in
                            Text(user.phoneNumber ?? "")
                        }
                        TableColumn("Photourl") { user in
                            Text(user.photoUrl ?? "")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        } detail: {
            if let selectedUser = store.selectedUser {
                VStack {
                    Text(selectedUser.uid!)
                    Text(selectedUser.email!)
                    Text(selectedUser.displayName!)
                    Text(selectedUser.phoneNumber ?? "No phone number")
                    Text(selectedUser.photoUrl ?? "No photo url")
                }
            }
        }
        .animation(.bouncy, value: store.selection)
        .onAppear { store.send(.onAppear) }
        .navigationTitle("Admin app")
    }
}


#Preview {
    AdminAppView(
        store: .init(
            initialState: .init(),
            reducer: {
                AdminApp()
            }
        )
    )
}
