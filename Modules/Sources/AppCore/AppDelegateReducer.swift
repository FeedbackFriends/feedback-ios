import ComposableArchitecture
import DependencyClients
import Helpers
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
        case didFinishLaunchingWithOptions(deviceId: String)
        case didReceiveRegistrationToken(String?)
        case didReceiveNotification(NotificationType)
        case authenticationStateChanged(UserState)
        case setupStateListener
        public enum NotificationType {
            case startFeedback(code: Int, email: String)
            case viewMeeting(meetingID: Int, email: String)
            case teamInvite(email: String)
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
                
            case .didFinishLaunchingWithOptions(let deviceId):
                logger.addCrashlyticsClient(deviceId: deviceId, minLevel: .error)
                logger.addOSLogClient(subsystem: Bundle.main.bundleIdentifier!, category: "LoggingClient")
                return .run { send in
                    let userStateChangedStream = await authClient.userStateChanged()
                    await send(.setupStateListener)
                    for await loggedInUser in userStateChangedStream {
                        await send(.authenticationStateChanged(loggedInUser))
                    }
                }
                
            case .didReceiveRegistrationToken(let fcmToken):
                return .run { send in
                    try await apiClient.updateFcmToken(fcmToken)
                }
                
            case .didReceiveNotification(_):
                fatalError("Notifications not implemented")
//                switch notification {
//                    
//                case .startFeedback(code: let code, email: let email):
//                    fatalError("Todo")
//                case .viewMeeting(meetingID: let meetingID, email: let email):
//                    fatalError("Todo")
//                case .teamInvite(email: let email):
//                    fatalError("Todo")
//                }
//                return .none
                
            case .setupStateListener:
                return .run { send in
                    await authClient.setupStateListener()
                }
            }
        }
    }
}



