import ComposableArchitecture
import DependencyClients
import AppCore
import Combine
import FirebaseAuth
import FirebaseCore
import FirebasePerformance
import FirebaseMessaging
import FirebaseCrashlytics
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


@main
struct FeedbackApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppCoreView(store: appDelegate.intialStore)
                
        }
    }
}


final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let intialStore = Store(
        initialState: AppCore.State()
    ) {
        AppCore()
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
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        startApp()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        intialStore.send(.appDelegate(.didFinishLaunchingWithOptions(deviceId: deviceId)))
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        intialStore.send(.appDelegate(.didReceiveRegistrationToken(fcmToken)))
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
        ) -> Void ) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        completionHandler([[.banner]])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    }
}

enum NotificationTypeString: String {
    case startFeedback = "START_FEEDBACK"
    case viewMeeting = "VIEW_MEETING"
    case teamInvite = "TEAM_INVITE"
}
