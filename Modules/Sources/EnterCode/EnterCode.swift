import DependencyClients
import Combine
import DependencyClients
import DesignSystem
import DependencyClients
import Foundation
import UserNotifications
import ComposableArchitecture
import SwiftUI

@Reducer
public struct EnterCode {
    
    @Reducer
    public enum Destination {
        @ReducerCaseIgnored
        case notificationPermission
    }
    
    @ObservableState
    public struct State {
        var inputCode: String = ""
        @Presents var destination: Destination.State?
        public var startFeedbackInFlight = false
        var disableStartFeedbackButton: Bool {
            if !PinCodeValidator.isValidPinCode(inputCode) || startFeedbackInFlight {
                return true
            }
            return false
        }
        public init() {}
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case onContinueNotificationPermissionButtonTap
        case notificationPermissionStatus(UserNotificationClient.Notification.Settings)
        case requestAuthorizationResponse(didAllowNotifications: Bool)
        case startFeedbackButtonTap
        case delegate(Delegate)
        public enum Delegate {
            case startFeedback(pinCode: String)
        }
    }
    
    public init() {}
    
    @Dependency(\.userNotifications) var userNotifications
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .onContinueNotificationPermissionButtonTap:
                return .run { send in
                    let didAllowNotifications = try await self.userNotifications.requestAuthorization([.alert, .sound])
                    try await Task.sleep(for: .seconds(0.5))
                    await send(.requestAuthorizationResponse(didAllowNotifications: didAllowNotifications))
                }
            case .notificationPermissionStatus(let notificationPermissionStatus):
                if case .notDetermined = notificationPermissionStatus.authorizationStatus {
                    state.destination = .notificationPermission
                }
                return .none
                
            case .requestAuthorizationResponse:
                return .run { send in
                    await dismiss()
                }
                
            case .startFeedbackButtonTap:
                let input = state.inputCode
                state.inputCode = ""
                state.startFeedbackInFlight = true
                return .send(.delegate(.startFeedback(pinCode: input)))
                
            case .delegate(_):
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}


