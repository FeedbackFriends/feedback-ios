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
        case alert(AlertState<Never>)
        @ReducerCaseEphemeral
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        public enum ConfirmationDialog {
            case logoutConfirmed
        }
    }
    
    @ObservableState
    public struct State: Equatable {
        #warning("Remember to update link")
        let url = URL(string: "https://www.google.com/")!
        let string = mockString
        @Presents var destination: Destination.State?
        var appVersion = "Version" //Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        @Shared var session: Session
        #if !RELEASE
        var idToken: String?
        #endif
        
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
        case firebaseIdTokenResponse(String?)
        case signOutButtonTapped
        case presentError(Error)
        case binding(BindingAction<State>)
        case signUpButtonTap
        case delegate(Delegate)
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
        Reduce { state, action in
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
                    #if !RELEASE
                    let idToken = try! await firebaseClient.getIDToken()
                    await send(.firebaseIdTokenResponse(idToken))
                    #endif
                }
                
            case .onNotificationsButtonTap:
                return .run { _ in
                    guard let settingsURL = URL(string: await systemClient.openSettingsURLString()) else { return }
                    await openURL(settingsURL)
                }
                
            case .onFeedbackButtonTap:
                return .run { _ in
                    let subject = "Feedback, \(deviceInformation)"
                    let body = ""
                    let url: URL = .emailURL(subject: subject, body: body)
                    await openURL(url)
                }
                
            case .onReportBugButtonTap:
                return .run { _ in
                    let subject = "Bug, \(deviceInformation)"
                    let body = ""
                    let url: URL = .emailURL(subject: subject, body: body)
                    await openURL(url)
                }
                
            case .onSupportUsButtonTap:
                guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1502217102?action=write-review")
                else { fatalError("Expected a valid URL") }
                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                return .none
                
            case .destination:
                return .none
                
            case .firebaseIdTokenResponse(let idToken):
                state.idToken = idToken
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
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

var deviceInformation: String {
    let version = "Bundle.main.versionNumber"
    let build = "Bundle.main.buildNumber"
    let os = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    return "v\(version)(\(build)), \(os)"
}

extension URL {
    static func emailURL(subject: String, body: String) -> Self {
        let string = "mailto:feedback.app.cph@gmail.com?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: string!)
        return url!
    }
}

var mockString = """
    [Your App Name] Privacy Policy
    
    This Privacy Policy describes how [Your Company Name] ("we," "us," or "our") collects, uses, and shares personal information when you use our mobile application [Your App Name] ("the App").
    
    Information We Collect
    1.1 Personal Information: When you use the App, we may collect the following personal information:
    
    [Specify the types of personal information you collect, such as names, email addresses, or contact information].
    1.2 Usage Data: We may also collect certain information automatically when you use the App, including:
    
    [Specify the types of usage data you collect, such as device information, IP addresses, or log files].
    Use of Information
    2.1 We may use the collected information for the following purposes:
    
    [Specify how you use the personal information, such as to provide and improve the App's functionality, personalize user experience, or communicate with users].
    2.2 We may use the usage data for the following purposes:
    
    [Specify how you use the usage data, such as for analytics, troubleshooting, or to enhance the App's performance].
    Sharing of Information
    3.1 We may share personal information with third parties in the following circumstances:
    
    [Specify the types of third parties you share information with, such as service providers, analytics platforms, or marketing partners].
    3.2 We may also disclose personal information if required by law or in response to valid requests by public authorities.
    
    Data Security
    4.1 We take reasonable measures to protect the security of your personal information and prevent unauthorized access, use, or disclosure.
    
    Third-Party Services
    5.1 The App may include links to third-party websites, services, or applications. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies before providing any personal information.
    
    Your Choices
    6.1 You can usually choose not to provide certain information by not using specific features of the App.
    
    Children's Privacy
    7.1 The App is not intended for individuals under the age of [specify the age limit] and we do not knowingly collect personal information from children. If you believe we have collected personal information from a child under the applicable age limit, please contact us.
    
    Updates to this Privacy Policy
    8.1 We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.
    
    Contact Us
    9.1 If you have any questions or concerns about this Privacy Policy, please contact us at [provide contact information].
    
    Remember, this template is a general starting point, and you should tailor it to your specific app and the data you collect. Always consult with a legal professional to ensure compliance with the applicable laws and regulations in your jurisdiction.
    """

