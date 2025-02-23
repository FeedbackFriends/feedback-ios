import Combine
import DependencyClients
import Foundation
import DesignSystem
import FirebaseAuth
import UIKit
import Helpers
import ComposableArchitecture
import Helpers
import Helpers

@Reducer
public struct More {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case modifyAccount(ModifyAccount)
        case alert(AlertState<Never>)
        case changeUserType(ChangeUserType)
        @ReducerCaseEphemeral
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        public enum ConfirmationDialog: Equatable {
            case logoutConfirmed
        }
    }
    
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
        @Presents var destination: Destination.State?
        var appVersion = "todo" //Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Version"
        @Shared var session: Session
        
        public init(session: Shared<Session>) {
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case onNotificationsButtonTap
        case onFeedbackButtonTap
        case onReportBugButtonTap
        case onSupportUsButtonTap
        case destination(PresentationAction<Destination.Action>)
        case signOutButtonTapped
        
        case presentError(Error)
        case binding(BindingAction<State>)
        case signUpButtonTap
        case delegate(Delegate)
        case changeUserTypeButtonTap
        case updateProfileButtonTap
        public enum Delegate {
            case navigateToSignUp
        }
    }
    
    public init() {}
    
    @Dependency(\.openURL) var openURL
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.logClient) var logger
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
            action in
            switch action {
                
            case .destination(.presented(.confirmationDialog(let confirmationDialogAction))):
                switch confirmationDialogAction {
                case .logoutConfirmed:
                    return .run { send in
                        do {
                            try authClient.logout()
                        } catch let error {
                            await send(.presentError(error))
                        }
                    }
                }
                
            case .onNotificationsButtonTap:
                return .run { _ in
                    guard let settingsURL = URL(string: await systemClient.openSettingsURLString()) else { return }
                    await openURL(settingsURL)
                }
                
            case .onFeedbackButtonTap:
                let subject = "Feedback, \(deviceInformation)"
                let body = ""
                return .run { send in
                    await openURL(systemClient.appleMailUrl(subject, body))
                }
                
            case .onReportBugButtonTap:
                let subject = "Bug, \(deviceInformation)"
                let body = ""
                return .run { send in
                    await openURL(systemClient.appleMailUrl(subject, body))
                }
                
            case .onSupportUsButtonTap:
                return .run { send in
                    await openURL(systemClient.appStoreReviewUrl())
                }
                
            case .destination:
                return .none
                
            case .signOutButtonTapped:
                state.destination = .confirmationDialog(
                    ConfirmationDialogState<Destination.ConfirmationDialog>(
                        title: { TextState("Are you sure you want to logout?") },
                        actions: {
                            ButtonState(role: .cancel, label: { TextState("Cancel") })
                            ButtonState(role: .destructive, action: .logoutConfirmed, label: { TextState("Logout") })
                        }
                    )
                )
                return .none
                
            case .presentError(let error):
                state.destination = .alert(.init(error: error))
                return .none
                
            case .binding:
                return .none
                
            case .signUpButtonTap:
                return .send(.delegate(.navigateToSignUp))
                
            case .delegate:
                return .none
                
            case .changeUserTypeButtonTap:
                guard let role = state.session.role else {
                    logger.log(.fault, "Change user button tap - Role in session is nil, should never happen")
                    return .none
                }
                state.destination = .changeUserType(.init(selectedUserType: role))
                return .none
                
            case .updateProfileButtonTap:
                switch state.session.userType {
                    
                case .manager(managerData: _, accountInfo: let accountInfo), .participant(accountInfo: let accountInfo):
                    state.destination = .modifyAccount(
                        .init(
                            nameInput: accountInfo.name ?? "",
                            emailInput: accountInfo.email ?? "",
                            phoneNumberInput: accountInfo.phoneNumber ?? ""
                        )
                    )
                    return .none
                case .anonymoous:
                    logger.log(.fault, "Update user type button tap with an anonymous account, should never happen")
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

var deviceInformation: String {
    let version = Bundle.main.versionNumber
    let build = Bundle.main.buildNumber
    let os = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    return "v\(version)(\(build)), \(os)"
}
