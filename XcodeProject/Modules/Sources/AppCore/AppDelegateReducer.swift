import ComposableArchitecture
import Model
import Logger
import Foundation

@Reducer
public struct AppDelegateReducer {
    @ObservableState
    public struct State {
        public init() {}
    }
    public enum Action {
        case didFinishLaunchingWithOptions
        case didReceiveRegistrationToken(String?)
        case authenticationStateChanged(UserState)
    }
    
    public init() {}
    @Dependency(\.authClient) var authClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .authenticationStateChanged(_):
                return .none
                
            case .didFinishLaunchingWithOptions:
                return .run { send in
                    let userStateChangedStream = await authClient.userStateChanged()
                    for await loggedInUser in userStateChangedStream {
                        Logger.debug("🔐 Auth state changed to: \(loggedInUser)")
                        await send(.authenticationStateChanged(loggedInUser), animation: .bouncy(duration: 1))
                    }
                }
                
            case .didReceiveRegistrationToken(let fcmToken):
                guard let fcmToken else { return .none }
                return .run { send in
                    do {
                        try await apiClient.linkFCMTokenToAccount(fcmToken)
                    } catch {
                        Logger.log(.error, "Update fcm token api call failed silently with error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
