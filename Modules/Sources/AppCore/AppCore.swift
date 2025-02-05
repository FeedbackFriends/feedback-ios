import Combine
import ComposableArchitecture
import LoggedInFeature
import Network
import DesignSystem
import DependencyClients
import APIClient
import Helpers
import EventsFeature
import Logger
import Foundation

@Reducer
public struct AppCore {
     
    @Reducer
    public enum Destination {
        case signUp(SignUp)
        @ReducerCaseIgnored
        case error(ErrorType)
        case loggedIn(Tabbar)
        @ReducerCaseEphemeral
        case isLoading
    }
    
    public enum ErrorType {
        case handleAuthenticatedAccountError(Error)
        case anonymousSignUpError(Error)
        case createAccountError(Error, Claim?)
        case getSessionError(Error)
        public func errorDescription() -> String {
            switch self {
            case .anonymousSignUpError(let error):
                error.localizedDescription
            case .createAccountError(let error, _):
                error.localizedDescription
            case .getSessionError(let error):
                error.localizedDescription
            case .handleAuthenticatedAccountError(let error):
                error.localizedDescription
            }
        }
    }
    
    @ObservableState
    public struct State {
        var firstTime = false
        var destination: Destination.State = .isLoading
        var isLoading = false
        var appDelegate: AppDelegateReducer.State = .init()
        var selectedUserType: Claim?
        var disableUserTypeSelectionButton: Bool {
            selectedUserType == nil
        }
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onLogoutButtonTap
        case appDelegate(AppDelegateReducer.Action)
        case destination(Destination.Action)
        case getSessionResponse(Session)
        case presentError(ErrorType)
        case onAppear
        case authenticationStateChanged(UserState)
        case onOpenURL(URL)
        case tryAgainButtonTap(ErrorType)
        case createAccountResponse(Session, Claim?)
        case navigateToSelectUserType
    }
    
    private func createAccount(
        withClaim claim: Claim?,
        state: inout State
    ) -> EffectOf<Self> {
        state.isLoading = true
        return .run  { send in
            do {
                let session = try await apiClient.createAccount(claim)
                await send(.createAccountResponse(session, claim), animation: .bouncy)
            } catch {
                await send(.presentError(ErrorType.createAccountError(error, claim)))
            }
        }
    }
    
    private func signUpAnonymously(
        state: inout State
    ) -> EffectOf<Self> {
        state.isLoading = true
        return .run  { send in
            do {
                try await firebaseClient.signInAnonymously()
            } catch {
                await send(.presentError(ErrorType.anonymousSignUpError(error)))
            }
        }
    }
    
    private func getSession(state: inout State) -> EffectOf<Self> {
        state.isLoading = true
        return .run  { send in
            do {
                let session = try await apiClient.getSession()
                await send(.getSessionResponse(session), animation: .bouncy)
            } catch {
                await send(.presentError(ErrorType.getSessionError(error)))
            }
        }
    }
    
    private func handeAuthenticatedAccount(state: inout State) -> EffectOf<Self> {
        state.isLoading = true
        return .run { send in
            do {
                let existingClaim = try await firebaseClient.fetchCustomClaim()
                guard let existingClaim else {
                    await send(.navigateToSelectUserType)
                    return
                }
                let session = try await apiClient.createAccount(existingClaim)
                await send(.createAccountResponse(session, existingClaim))
            } catch {
                await send(.presentError(.handleAuthenticatedAccountError(error)))
            }
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.firebaseClient) var firebaseClient
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
                
            case .destination(.loggedIn(.more(.destination(.presented(.changeUserType(.delegate(.refreshSession))))))):
                return getSession(state: &state)
                
            case .destination(.loggedIn(.eventsOverview(.delegate(.navigateToSignUp)))),
                    .destination(.loggedIn(.more(.delegate(.navigateToSignUp)))):
                state.destination = .signUp(.init())
                return .none
                
            case .tryAgainButtonTap(let errorType):
                state.isLoading = true
                switch errorType {
                    
                case .anonymousSignUpError(_):
                    return signUpAnonymously(state: &state)
                    
                case .createAccountError(_, let claim):
                    return createAccount(withClaim: claim, state: &state)
                    
                case .getSessionError(_):
                    return getSession(state: &state)
                case .handleAuthenticatedAccountError(_):
                    return handeAuthenticatedAccount(state: &state)
                }
                
            case .onLogoutButtonTap:
                return .run { send in
                    try firebaseClient.logout()
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
                        eventsOverview: .init(session: sharedSession),
                        enterCode: .init(),
                        selectedTab: .feedback
                    )
                )
                return .none
                
            case .presentError(let errorType):
                logger.log(.error, "Received error in app core: \(errorType.errorDescription())", nil)
                state.isLoading = false
                state.destination = .error(errorType)
                return .none
                
            case .onAppear:
                guard state.firstTime else {
                    state.firstTime = true
                    return .merge(
                        .run { send in
                            try await firebaseClient.setup()
                            let userStateChangedStream =
                            firebaseClient.userStateChanged()
//                            AsyncStream.debounced(
//                                from: firebaseClient.userStateChanged(),
//                                debounceIntervalNanoSeconds: 500_000_000
//                            )
                            for await loggedInUser in userStateChangedStream {
                                await send(.authenticationStateChanged(loggedInUser))
                            }
                        }
                    )
                }
                return .none
                
            case .authenticationStateChanged(let authState):
                logger.log("🐸 Auth state changed: \(authState)")
                switch authState {
                    
                case .authenticated:
                    return handeAuthenticatedAccount(state: &state)
                    
                case .anonymous:
                    return createAccount(withClaim: nil, state: &state)
                    
                case .loggedOut:
                    /// This is triggered when app is opened
                    if case .isLoading = state.destination {
                        return signUpAnonymously(state: &state)
                    } else {
                        state.destination = .signUp(.init())
                        return .none
                    }
                }
                
            case .navigateToSelectUserType:
                state.destination = .signUp(.init(destination: .selectUserType(.init())))
                state.isLoading = false
                return .none
                
            case .createAccountResponse(let session, _):
                let sharedSession = Shared(value: session)
                state.destination = Destination.State.loggedIn(
                    Tabbar.State(
                        session: sharedSession,
                        eventsOverview: .init(session: sharedSession),
                        enterCode: .init(),
                        selectedTab: .feedback
                    )
                )
                return .none
                
            case .onOpenURL(let url):
                guard url.scheme == "letsgrow",
                      let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                      let pinCode = components
                    .path
                    .components(separatedBy: "/")
                    .last(where: { !$0.isEmpty && $0 != "invite" }) else {
                    return .none
                }
                
                switch state.destination {
                case .loggedIn(let existingState):
                    let session = Shared(value: existingState.session)
                    let newState = Destination.State.loggedIn(
                        Tabbar.State(
                            session: session,
                            eventsOverview: .init(destination: .joinEvent(.init(inputCode: String(pinCode))), session: session),
                            enterCode: .init(),
                            selectedTab: .events
                        )
                    )
                    state.destination = newState
                    return .none
                default:
                    /// Todo: we could also handle other cases here. Maybe present an alert that you need to be logged in or something
                    return .none
                }
            }
        }
        ._printChanges()
    }
}

extension AsyncStream {
    static func debounced(
        from stream: AsyncStream<Element>,
        debounceIntervalNanoSeconds: UInt64
    ) -> AsyncStream<Element> {
        AsyncStream { continuation in
            Task {
                var lastEmissionTime: UInt64 = 0
                
                for await value in stream {
                    let now = DispatchTime.now().uptimeNanoseconds
                    if now - lastEmissionTime > debounceIntervalNanoSeconds {
                        continuation.yield(value)
                        lastEmissionTime = now
                    }
                }
                
                continuation.finish()
            }
        }
    }
}
