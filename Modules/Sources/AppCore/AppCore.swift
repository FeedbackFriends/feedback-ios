import Combine
import ComposableArchitecture
import Tabbar
import Network
import DesignSystem
import Helpers
import EventsFeature
import Logger
import Foundation

@Reducer
public struct AppCore {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case signUp(SignUp)
        @ReducerCaseIgnored
        case error(ErrorType)
        case loggedIn(Tabbar)
        @ReducerCaseEphemeral
        case isLoading
    }
    
    public enum ErrorType: Equatable {
        case handleAuthenticatedAccountError(error: PresentableError)
        case anonymousSignUpError(error: PresentableError)
        case createAccountError(error: PresentableError, Role?)
        case getSessionError(error: PresentableError)
        var error: PresentableError {
            switch self {
            case .handleAuthenticatedAccountError(let error):
                return error
            case .anonymousSignUpError(let error):
                return error
            case .createAccountError(let error, _):
                return error
            case .getSessionError(let error):
                return error
            }
        }
    }
    
    @ObservableState
    public struct State {
        var destination: Destination.State = .isLoading
        var isLoading = false
        var appDelegate: AppDelegateReducer.State = .init()
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onLogoutButtonTap
        case appDelegate(AppDelegateReducer.Action)
        case destination(Destination.Action)
        case getSessionResponse(Session)
        case presentError(ErrorType)
        case onOpenURL(URL)
        case tryAgainButtonTap(ErrorType)
        case createAccountResponse(Session, Role?)
        case navigateToSelectUserType
    }
    
    private func createAccount(
        withRole role: Role?,
        state: inout State
    ) -> EffectOf<Self> {
        state.isLoading = true
        return .run  { send in
            do {
                let session = try await apiClient.createAccount(role)
                await send(.createAccountResponse(session, role))
            } catch {
                await send(.presentError(ErrorType.createAccountError(error: error.localized, role)))
            }
        }
    }
    
    private func signUpAnonymously(
        state: inout State
    ) -> EffectOf<Self> {
        state.isLoading = true
        return .run  { send in
            do {
                try await authClient.signInAnonymously()
            } catch {
                await send(.presentError(ErrorType.anonymousSignUpError(error: error.localized)))
            }
        }
    }
    
    private func getSession(state: inout State) -> EffectOf<Self> {
        state.isLoading = true
        return .run  { send in
            do {
                let session = try await apiClient.getSession()
                await send(.getSessionResponse(session))
            } catch {
                await send(.presentError(ErrorType.getSessionError(error: error.localized)))
            }
        }
    }
    
    private func handeAuthenticatedAccount(state: inout State) -> EffectOf<Self> {
        state.isLoading = true
        return .run { send in
            do {
                let existingRole = try await authClient.fetchCustomRole()
                guard let existingRole else {
                    await send(.navigateToSelectUserType)
                    return
                }
                let session = try await apiClient.createAccount(existingRole)
                await send(.createAccountResponse(session, existingRole))
            } catch {
                await send(.presentError(.handleAuthenticatedAccountError(error: error.localized)))
            }
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.continuousClock) var clock
    @Dependency(\.logClient) var logger
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegateReducer()
        }
        Scope(state: \.destination, action: \.destination) {
            Destination.body
        }
        Reduce {
            state,
            action in
            switch action {
                
            case .destination(.signUp(.destination(.presented(.selectUserType(.delegate(.getSession)))))):
                return getSession(state: &state)
                
            case .destination(.loggedIn(.accountSection(.destination(.presented(.changeUserType(.delegate(.refreshSession))))))):
                return getSession(state: &state)
                
            case .destination(.loggedIn(.delegate(.navigateToSignUp))),
                    .destination(.loggedIn(.participantEvents(.delegate(.navigateToSignUp)))):
                state.destination = .signUp(.init())
                return .none
                
            case .tryAgainButtonTap(let errorType):
                state.isLoading = true
                switch errorType {
                    
                case .anonymousSignUpError:
                    return signUpAnonymously(state: &state)
                    
                case .createAccountError(_, let role):
                    return createAccount(withRole: role, state: &state)
                    
                case .getSessionError(_):
                    return getSession(state: &state)
                case .handleAuthenticatedAccountError(_):
                    return handeAuthenticatedAccount(state: &state)
                }
                
            case .onLogoutButtonTap:
                return .run { send in
                    try await authClient.logout()
                }
                
            case .appDelegate(.authenticationStateChanged(let authState)):
                logger.log("🐸 Auth state changed: \(authState)")
                switch authState {
                    
                case .authenticated:
                    return handeAuthenticatedAccount(state: &state)
                    
                case .anonymous:
                    return createAccount(withRole: nil, state: &state)
                    
                case .loggedOut:
                    /// This is triggered when app is opened
                    if case .isLoading = state.destination {
                        return signUpAnonymously(state: &state)
                    } else {
                        state.destination = .signUp(.init())
                        return .none
                    }
                }
                
            case .appDelegate:
                return .none
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .getSessionResponse(let session):
                let sharedSession = Shared(value: session)
                state.destination = Destination.State.loggedIn(
                    Tabbar.State(
                        session: sharedSession,
                        selectedTab: .feedback
                    )
                )
                return .none
                
            case .presentError(let errorType):
                logger.log(.default, "Received error in app core: \(errorType)", nil)
                state.isLoading = false
                state.destination = .error(errorType)
                return .none
                
            case .navigateToSelectUserType:
                state.destination = .signUp(.init(destination: .selectUserType(.init())))
                state.isLoading = false
                return .none
                
            case .createAccountResponse(let session, _):
                let sharedSession = Shared(value: session)
                state.destination = Destination.State.loggedIn(
                    Tabbar.State(
                        session: sharedSession,
                        selectedTab: .feedback
                    )
                )
                return .none
                
            case .onOpenURL(let url):
                guard let deepLink = url.parseDeepLink() else {
                    return .none
                }
                switch (deepLink, state.destination) {
                case let (.joinEvent(pinCodeInput), .loggedIn(existingState)):
                    let session = Shared(value: existingState.session)
                    let newState = Destination.State.loggedIn(
                        Tabbar.State(
                            session: session,
                            destination: .joinEvent(.init(pinCodeInput: pinCodeInput))
                        )
                    )
                    state.destination = newState
                    return .none
                    
                default:
                    return .none
                }
            }
        }
        ._printChanges()
    }
}
