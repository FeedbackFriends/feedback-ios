import ComposableArchitecture
import Helpers
import AppCore
import Combine
import FirebaseAuth
import FirebaseCore
import FirebasePerformance
import FirebaseMessaging
import FirebaseCrashlytics
import GoogleSignIn
import Tabbar
import DesignSystem
import SwiftUI
import UIKit
import UserNotifications
import Firebase
import UserNotifications
import EnterCode
import Logger

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let intialStore = Store(
        initialState: AppCore.State()
    ) {
        AppCore()
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        startApp()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        intialStore.send(.appDelegate(.didFinishLaunchingWithOptions))
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM token received: \(fcmToken ?? "Not found")")
        intialStore.send(.appDelegate(.didReceiveRegistrationToken(fcmToken)))
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().setAPNSToken(deviceToken as Data, type: .prod)
        print("APNS Token Set: \(deviceToken)")
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
