import ComposableArchitecture
import Model
import AppCore
import FirebaseAuth
import FirebaseCore
import FirebasePerformance
import FirebaseMessaging
import FirebaseCrashlytics
import DesignSystem
import UIKit
import Logger
import Implementations
import Utility
import OpenAPI
import OpenAPIURLSession
import OpenAPIRuntime
import InfoPlist

public enum InfoPlistConfig {
    
    public static var apiBaseUrl: URL {
        InfoPlist().url(for: "API_BASE_URL", scheme: "API_SCHEME")!
    }
    public static var supportEmail: String {
        InfoPlist().string(for: "SUPPORT_EMAIL")!
    }
    public static var webBaseUrl: URL {
        InfoPlist().url(for: "WEB_BASE_URL", scheme: "WEB_SCHEME")!
    }
    public static var appStoreId: String {
        InfoPlist().string(for: "APPSTORE_ID")!
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    
    let intialStore = Store(
        initialState: AppCore.State()
    ) {
        AppCore()._printChanges()
    } withDependencies: {
        $0.webURLClient = .live(
            webBaseUrl: InfoPlistConfig.webBaseUrl,
            appStoreId: InfoPlistConfig.appStoreId
        )
        $0.systemClient = .live(supportEmail: InfoPlistConfig.supportEmail)
        $0.notificationClient = .live
        $0.authClient = .live
        $0.apiClient = .live(
            client: Client(
                serverURL: InfoPlistConfig.apiBaseUrl,
                configuration: Configuration(),
                transport: URLSessionTransport(),
                middlewares: [
                    AuthorisationMiddleware(),
                    DelayMiddleware(),
                    DeviceIdHeaderMiddleware(deviceId: DeviceInfo().deviceID())
                ]
            ),
            provideFcmToken: {
                try? await Messaging.messaging().token()
            }
        )
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
                OSLogClient(subsystem: DeviceInfo().bundleIdentifier(), category: "LoggingClient")
            ]
        )
        intialStore.send(.onAppOpen)
        return true
    }
    
    /// When a notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let deeplink = DeeplinkParser.fromNotificationPayload(response.notification.request.content.userInfo) else { return }
        intialStore.send(.onNotificationTap(deeplink))
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        intialStore.send(.didReceiveFCMToken(fcmToken))
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
