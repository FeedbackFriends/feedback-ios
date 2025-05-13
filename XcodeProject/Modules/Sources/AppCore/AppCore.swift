import Combine
import ComposableArchitecture
import TabbarFeature
import Network
import SignUpFeature
import DesignSystem
import Model
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
        case getSessionError(error: PresentableError, deeplink: Deeplink?)
        var error: PresentableError {
            switch self {
            case .handleAuthenticatedAccountError(let error):
                return error
            case .anonymousSignUpError(let error):
                return error
            case .createAccountError(let error, _):
                return error
            case .getSessionError(let error, _):
                return error
            }
        }
    }
    
    @ObservableState
    public struct State {
        var destination: Destination.State
        var isLoading: Bool
        var appDelegate: AppDelegateReducer.State
        var logout: Logout.State
        public init(
            destination: Destination.State = .isLoading,
            isLoading: Bool = false,
            appDelegate: AppDelegateReducer.State = .init(),
            logout: Logout.State = .init()
        ) {
            self.destination = destination
            self.isLoading = isLoading
            self.appDelegate = appDelegate
            self.logout = logout
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case appDelegate(AppDelegateReducer.Action)
        case destination(Destination.Action)
        case getSessionResponse(session: Session, deeplink: Deeplink?)
        case presentError(ErrorType)
        case tryAgainButtonTap(ErrorType)
        case createAccountResponse(Session, Role?)
        case navigateToSelectUserType
        case logout(Logout.Action)
        case onNotificationTap(Deeplink)
        case onUrlOpen(Deeplink)
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
    
    private func getSession(state: inout State, deeplink: Deeplink?) -> EffectOf<Self> {
        state.isLoading = true
        return .run  { send in
            do {
                let session = try await apiClient.getSession()
                await send(.getSessionResponse(session: session, deeplink: deeplink))
            } catch {
                await send(.presentError(ErrorType.getSessionError(error: error.localized, deeplink: deeplink)))
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
    
    private func handleDeeplink(state: inout State, deeplink: Deeplink) -> EffectOf<Self> {
        guard case let .loggedIn(existingState) = state.destination else { return .none }
        let session = Shared(value: existingState.session)
        if deeplink.sessionRefreshNeeded {
            state.isLoading = true
            return .run  { send in
                do {
                    let session = try await apiClient.getSession()
                    await send(.getSessionResponse(session: session, deeplink: deeplink))
                } catch {
                    await send(.presentError(ErrorType.getSessionError(error: error.localized, deeplink: deeplink)))
                }
            }
        }
        state = .fromDeeplink(deeplink: deeplink, sharedSession: session)
        return .none
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegateReducer()
        }
        Scope(state: \.logout, action: \.logout) {
            Logout()
        }
        Scope(state: \.destination, action: \.destination) {
            Destination.body
        }
        Reduce {
            state,
            action in
            switch action {
                
            case .destination(.signUp(.destination(.presented(.selectUserType(.delegate(.getSession)))))):
                return getSession(state: &state, deeplink: nil)
                
            case .destination(.loggedIn(.accountSection(.destination(.presented(.changeUserType(.delegate(.refreshSession))))))):
                return getSession(state: &state, deeplink: nil)
                
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
                    
                case .getSessionError(_, let deeplink):
                    return getSession(state: &state, deeplink: deeplink)
                    
                case .handleAuthenticatedAccountError(_):
                    return handeAuthenticatedAccount(state: &state)
                
                }
                
            case .appDelegate(.authenticationStateChanged(let authState)):
                Logger.debug("Auth state changed: \(authState)")
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
                
//            case .appDelegate(.handleNotification(let notificationLink)):
//                     state.destination = .isLoading
//                return getSession(state: &state, notificationLink: notificationLink)
                
            case .appDelegate:
                return .none
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .getSessionResponse(let session, let deeplink):
                let sharedSession = Shared(value: session)
                guard let deeplink else {
                    state.destination = Destination.State.loggedIn(
                        Tabbar.State(
                            session: sharedSession,
                            selectedTab: .feedback
                        )
                    )
                    return .none
                }
                state = .fromDeeplink(deeplink: deeplink, sharedSession: sharedSession)
                return .none
                
            case .presentError(let errorType):
                Logger.log(.default, "Received error in app core: \(errorType)", nil)
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
                
            case .logout:
                return .none
            case .onNotificationTap(let deeplink):
                return handleDeeplink(state: &state, deeplink: deeplink)
                
            case .onUrlOpen(let deeplink):
                return handleDeeplink(state: &state, deeplink: deeplink)
            }
        }
    }
}

extension AppCore.State {
    static func fromDeeplink(deeplink: Deeplink, sharedSession: Shared<Session>) -> Self {
        switch deeplink {
        case .joinEvent(let pinCodeInput):
            return AppCore.State(
                destination: AppCore.Destination.State.loggedIn(
                    Tabbar.State(
                        session: sharedSession,
                        destination: .joinEvent(
                            .init(pinCodeInput: pinCodeInput)
                        )
                    )
                )
            )
        case .managerEvent(let eventId):
            var newTabbarState = Tabbar.State(
                session: sharedSession
            )
            if let managerEvent = sharedSession.wrappedValue.managerData?.managerEvents[id: eventId] {
                newTabbarState.managerEvents.destination = .eventDetail(
                    .init(
                        event: managerEvent,
                        session: sharedSession
                    )
                )
            }
            return AppCore.State(
                destination: AppCore.Destination.State.loggedIn(
                    newTabbarState
                )
            )
        }
    }
}
