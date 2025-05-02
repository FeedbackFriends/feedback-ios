import Combine
import Model
import Foundation
import DesignSystem
import UIKit
import ComposableArchitecture
import Logger
import Utility

@Reducer
public struct MoreSection {
    
    @ObservableState
    public struct State: Equatable {
        var privacyPolicyUrl: URL {
            @Dependency(\.systemClient) var systemClient
            return systemClient.privacyPolicyUrl()
        }
        var appStoreReviewUrl: URL {
            @Dependency(\.systemClient) var systemClient
            return systemClient.appStoreReviewUrl()
        }
        
        public init() {}
    }
    
    public enum Action: BindableAction {
        case onNotificationsButtonTap
        case onFeedbackButtonTap
        case onReportBugButtonTap
        case onSupportUsButtonTap
        case binding(BindingAction<State>)
    }
    
    public init() {}
    
    @Dependency(\.openURL) var openURL
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.logClient) var logger
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onNotificationsButtonTap:
                return .run { _ in
                    guard let settingsURL = URL(string: await systemClient.openSettingsURLString()) else { return }
                    await openURL(settingsURL)
                }
                
            case .onFeedbackButtonTap:
                let subject = "Feedback, \(deviceInformation)"
                let body = ""
                return .run { send in
                    await openURL(systemClient.appleMailUrl(subject: subject, body: body))
                }
                
            case .onReportBugButtonTap:
                let subject = "Bug, \(deviceInformation)"
                let body = ""
                return .run { send in
                    await openURL(systemClient.appleMailUrl(subject: subject, body: body))
                }
                
            case .onSupportUsButtonTap:
                return .run { send in
                    await openURL(systemClient.appStoreReviewUrl())
                }
                
            case .binding:
                return .none
            }
        }
    }
}

var deviceInformation: String {
    let version = Bundle.main.versionNumber
    let build = Bundle.main.buildNumber
    let os = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    return "v\(version)(\(build)), \(os)"
}
