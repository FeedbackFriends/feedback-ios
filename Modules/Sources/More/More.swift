import Combine
import DependencyClients
import Foundation
import DesignSystem
import FirebaseAuth
import UIKit
import Helpers
import ComposableArchitecture
import APIClient

@Reducer
public struct More {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case modifyAccount(ModifyAccount)
        case alert(AlertState<Never>)
        case changeUserType(ChangeUserType)
        @ReducerCaseEphemeral
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        public enum ConfirmationDialog {
            case logoutConfirmed
        }
    }
    
    @ObservableState
    public struct State: Equatable {
        let url = URL(string: "https://www.google.com/")!
        @Presents var destination: Destination.State?
        var appVersion = "" //Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Version"
        @Shared var session: Session
        
        public init(session: Shared<Session>) {
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case task
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
    @Dependency(\.firebaseClient) var firebaseClient
    
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
                            try firebaseClient.logout()
                        } catch let error {
                            await send(.presentError(error))
                        }
                    }
                }
                
            case .task:
                //                let userInfo = firebaseClient.userInfo()
                //                state.email = userInfo.0
                //                state.name = userInfo.1
                return .run { send in
                    //                    #if !RELEASE
                    //                    let idToken = try! await firebaseClient.getIDToken()
                    //                    await send(.firebaseIdTokenResponse(idToken))
                    //                    #endif
                }
                
            case .onNotificationsButtonTap:
                return .run { _ in
                    guard let settingsURL = URL(string: await systemClient.openSettingsURLString()) else { return }
                    await openURL(settingsURL)
                }
                
            case .onFeedbackButtonTap:
                //                return .run { _ in
                //                    let subject = "Feedback, \(deviceInformation)"
                //                    let body = ""
                //                    let url: URL = .emailURL(subject: subject, body: body)
                //                    await openURL(url)
                //                }
                return .none
                
            case .onReportBugButtonTap:
                //                return .run { _ in
                //                    let subject = "Bug, \(deviceInformation)"
                //                    let body = ""
                //                    let url: URL = .emailURL(subject: subject, body: body)
                //                    await openURL(url)
                //                }
                return .none
                
            case .onSupportUsButtonTap:
                //                guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1502217102?action=write-review")
                //                else { fatalError("Expected a valid URL") }
                //                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                return .none
                
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
                state.destination = .alert(okErrorAlert(message: error.localizedDescription))
                return .none
                
            case .binding:
                return .none
                
            case .signUpButtonTap:
                return .send(.delegate(.navigateToSignUp))
                
            case .delegate:
                return .none
            case .changeUserTypeButtonTap:
                guard let claim = state.session.claim else {
                    assertionFailure("Change user button tap - Claim in session is nil, should never happen")
                    return .none
                }
                state.destination = .changeUserType(.init(selectedUserType: claim))
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
                    assertionFailure("Update user type button tap with an anonymous account, should never happen")
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

//var deviceInformation: String {
//    let version = "Bundle.main.versionNumber"
//    let build = "Bundle.main.buildNumber"
//    let os = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
//    return "v\(version)(\(build)), \(os)"
//}

extension URL {
    static func emailURL(subject: String, body: String) -> Self {
        let string = "mailto:feedback.app.cph@gmail.com?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: string!)
        return url!
    }
}
