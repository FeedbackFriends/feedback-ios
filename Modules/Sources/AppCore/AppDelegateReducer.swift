import ComposableArchitecture
import Helpers
import Logger
import Foundation

@Reducer
public struct AppDelegateReducer {
    @ObservableState
    public struct State {
        var didLoad: Bool = false
        public init() {}
    }
    public enum Action {
        case didFinishLaunchingWithOptions
        case didReceiveRegistrationToken(String?)
        case onTapNotification(NotificationType)
        case authenticationStateChanged(UserState)
        public enum NotificationType {
            public struct ReceivedFeedback {
                let eventId: String
                let eventTitle: String
            }
            case feedbackReceived(ReceivedFeedback)
        }
    }
    
    public init() {}
    @Dependency(\.authClient) var authClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.logClient) var logger
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
                        await send(.authenticationStateChanged(loggedInUser), animation: .bouncy(duration: 1))
                    }
                }
                
            case .didReceiveRegistrationToken(let fcmToken):
                return .run { send in
                    try await apiClient.updateFcmToken(fcmToken)
                }
                
            case .onTapNotification(_):
                return .none
            }
        }
    }
}



