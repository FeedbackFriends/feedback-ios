import ComposableArchitecture
import DependencyClients
import AppCore
import Combine
import FirebaseAuth
import FirebaseCore
import FirebasePerformance
import FirebaseMessaging
import GoogleSignIn
import LoggedInFeature
import DesignSystem
import SwiftUI
import UIKit
import UserNotifications
import Firebase
import UserNotifications
import EnterCode
import Logger

var deviceId: String {
    let key = "deviceId"
    guard let deviceId = UserDefaults.standard.string(forKey: key) else {
        let generatedDeviceId = UUID().uuidString
        UserDefaults.standard.set(generatedDeviceId, forKey: key)
        return generatedDeviceId
    }
    return deviceId
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let intialStore = Store(
        initialState: AppCore.State()
    ) {
        AppCore().transformDependency(\.self) { _ in
//            $0.audioPlayer = .liveValue
//            $0.database = .live(
//                path: FileManager.default
//                    .urls(for: .documentDirectory, in: .userDomainMask)
//                    .first!
//                    .appendingPathComponent("co.pointfree.Isowords")
//                    .appendingPathComponent("Isowords.sqlite3")
//            )
//            $0.serverConfig = .live(apiClient: $0.apiClient, build: $0.build)
//            $0.logClient.addCrashlyticsClient(deviceId: deviceId, minLevel: .error)
//            $0.logClient.addOSLogClient(subsystem: Bundle.main.bundleIdentifier!, category: "LoggingClient")
        }
    }
    
    
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = AppDelegate.self
        return sceneConfig
    }
//
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        @Dependency(\.logClient) var logger
        logger.addCrashlyticsClient(deviceId: deviceId, minLevel: .error)
        logger.addOSLogClient(subsystem: Bundle.main.bundleIdentifier!, category: "LoggingClient")
        // Firebase configuration is needed directly here and not in an interface
        // Otherwise microsoft login doesnt work as expected
        Messaging.messaging().delegate = self
        registerFonts()
        setupTheme()
        // Set UNUserNotificationCenterDelegate
        UNUserNotificationCenter.current().delegate = self
        
        intialStore.send(.appDelegate(.didFinishLaunchingWithOptions))
        
//            .task {
//                do {
       
//                } catch {
//                    fatalError("Error: \(error.localizedDescription)")
//                }
//            }
        
        return true
    }
    
//    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
//                Auth.auth().canHandle(url)
//        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
////        return GIDSignIn.sharedInstance.handle(url)
//    }
    
//    func application(
//        _ app: UIApplication,
//        open url: URL,
//        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
//    ) -> Bool {
//        return GIDSignIn.sharedInstance.handle(url)
//    }
}



extension AppDelegate: @preconcurrency MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        self.appViewModel.appdelegate(.didReceiveRegistrationToken(fcmToken))
        intialStore.send(.appDelegate(.didReceiveRegistrationToken(fcmToken)))
    }
}

@main
struct FeedbackApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppCoreView(store: appDelegate.intialStore)
                
        }
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            let url = urlContext.url
            _ = Auth.auth().canHandle(url)
        }
    }
//
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//
//        guard let urlContext = URLContexts.first else {
//            return
//        }
//
//        let url = urlContext.url
//        let sourceApp = urlContext.options.sourceApplication
//
//        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApp)
//    }
}

extension AppDelegate : @preconcurrency UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
        ) -> Void ) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.banner]])
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        
//        appViewModel.handleNotification()
//        
////        if let messageID = userInfo[gcmMessageIDKey] {
////            print("Message ID from userNotificationCenter didReceive: \(messageID)")
////        }
//        
//        completionHandler()
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        
//        let content = response.notification.request.content
//        
//        guard
//            let typeAsString = content.userInfo["type"] as? String,
//            let email = content.userInfo["email"] as? String,
//            let type = NotificationTypeString(rawValue: typeAsString) else { return }
        
//        switch type {
//        case .startFeedback:
//            guard let code = content.userInfo["code"] as? String, let codeAsInt = Int(code) else { return }
////            self.appViewModel.appdelegate(.didReceiveNotification(.startFeedback(code: codeAsInt, email: email)))
//            return
//            
//        case .viewMeeting:
//            guard let meetingID = content.userInfo["meetingID"] as? String,
//                  let meetingIDAsInt = Int(meetingID) else { return }
//            self.appViewModel.appdelegate(.didReceiveNotification(.viewMeeting(meetingID: meetingIDAsInt, email: email)))
//            return
//            
//        case .teamInvite:
//            self.appViewModel.appdelegate(.didReceiveNotification(.teamInvite(email: email)))
//            return
//        }
    }
}

enum NotificationTypeString: String {
    case startFeedback = "START_FEEDBACK"
    case viewMeeting = "VIEW_MEETING"
    case teamInvite = "TEAM_INVITE"
}
