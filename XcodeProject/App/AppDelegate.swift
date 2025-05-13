import ComposableArchitecture
import Model
import AppCore
import FirebaseAuth
import FirebaseCore
import FirebasePerformance
import FirebaseMessaging
import FirebaseCrashlytics
import GoogleSignIn
import DesignSystem
import SwiftUI
import UIKit
import Firebase
import UserNotifications
import Logger
import Implementations
import Utility

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let intialStore = Store(
        initialState: AppCore.State()
    ) {
        AppCore()._printChanges()
    }
    
    /// On app launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        AppTheme.setUp()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        Logger.setup(
            logClients: [
                CrashlyticsLoggingClient.create(deviceId: DeviceInfo().deviceID(), minLevel: .error),
                OSLogClient(subsystem: Bundle.main.bundleIdentifier!, category: "LoggingClient")
            ]
        )
        intialStore.send(.appDelegate(.didFinishLaunchingWithOptions))
        return true
    }
    
    /// When a notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let deeplink = DeeplinkParser.fromNotification(response) else { return }
        intialStore.send(.onNotificationTap(deeplink))
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        intialStore.send(.appDelegate(.didReceiveRegistrationToken(fcmToken)))
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken as Data, type: .prod)
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
