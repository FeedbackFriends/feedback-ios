import Model
import Foundation
import DesignSystem
import ComposableArchitecture
import Logger
import Utility

@Reducer
public struct MoreSection {
    
    @ObservableState
    public struct State: Equatable {
        var privacyPolicyUrl: URL?
        var appStoreReviewUrl: URL?
        public init() {}
    }
    
    public enum Action: BindableAction {
        case onNotificationsButtonTap
        case onFeedbackButtonTap
        case onReportBugButtonTap
        case onSupportUsButtonTap
        case binding(BindingAction<State>)
        case onAppear
    }
    
    public init() {}
    
    @Dependency(\.openURL) var openURL
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.webURLClient) var webURLClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                state.privacyPolicyUrl = try? webURLClient.privacyPolicyUrl()
                state.appStoreReviewUrl = try? webURLClient.appStoreReviewUrl()
                return .none
                
            case .onNotificationsButtonTap:
                return .run { _ in
                    guard let settingsURL = URL(string: await systemClient.openAppSettings()) else { return }
                    await openURL(settingsURL)
                }
                
            case .onFeedbackButtonTap:
                let subject = "Feedback"
                let body = """
                    <Add your message here>
                    
                    Device info
                    \(DeviceInfo().summary())
                    """
                return .run { _ in
                    await openURL(systemClient.openEmail(subject: subject, body: body))
                }
                
            case .onReportBugButtonTap:
                let subject = "Bug"
                let body = """
                    <Add your message here>
                    
                    Device info
                    \(DeviceInfo().summary())
                    """
                return .run { _ in
                    await openURL(systemClient.openEmail(subject: subject, body: body))
                }
                
            case .onSupportUsButtonTap:
                return .run { _ in
                    await openURL(try webURLClient.appStoreReviewUrl())
                }
                
            case .binding:
                return .none
            }
        }
    }
}
