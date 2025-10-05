import ComposableArchitecture
import Domain
import RootFeature
import FirebaseAuth
import FirebaseCore
import FirebasePerformance
import FirebaseMessaging
import FirebaseCrashlytics
import DesignSystem
import UIKit
import Logger
import Adapters
import Utility
import OpenAPI
import OpenAPIURLSession
import OpenAPIRuntime
import InfoPlist
import Sentry

public enum InfoPlistConfig {
    
    public static var apiBaseUrl: URL {
        InfoPlist().url(for: "API_BASE_URL", scheme: "API_SCHEME")!
    }
    public static var sentryDsnUrl: URL {
        InfoPlist().url(for: "SENTRY_DSN_URL", scheme: "SENTRY_DSN_SCHEME")!
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
    public static var firebaseGoogleAppId: String {
        InfoPlist().string(for: "FIREBASE_GOOGLE_APP_ID")!
    }
    public static var firebaseGcmSenderId: String {
        InfoPlist().string(for: "FIREBASE_GCM_SENDER_ID")!
    }
    public static var firebaseClientId: String {
        InfoPlist().string(for: "FIREBASE_CLIENT_ID")!
    }
    public static var firebaseApiKey: String {
        InfoPlist().string(for: "FIREBASE_API_KEY")!
    }
    public static var firebaseBundleId: String {
        InfoPlist().string(for: "FIREBASE_BUNDLE_ID")!
    }
    public static var firebaseProjectId: String {
        InfoPlist().string(for: "FIREBASE_PROJECT_ID")!
    }
    public static var firebaseStorageBucket: String {
        InfoPlist().string(for: "FIREBASE_STORAGE_BUCKET")!
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let apiClient: APIClient = .live(
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
    let notificationClient: NotificationClient = .live
    
    lazy var intialStore = Store(
        initialState: RootFeature.State()
    ) {
        RootFeature()._printChanges()
    } withDependencies: {
        $0.webURLClient = .live(
            webBaseUrl: InfoPlistConfig.webBaseUrl,
            appStoreId: InfoPlistConfig.appStoreId
        )
        $0.systemClient = .live(supportEmail: InfoPlistConfig.supportEmail)
        $0.notificationClient = self.notificationClient
        $0.authClient = .live
        $0.apiClient = self.apiClient
    }
    
    /// On app launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        SentrySDK.start { options in
            options.dsn = InfoPlistConfig.sentryDsnUrl.absoluteString
            options.debug = false
            options.tracesSampleRate = 0.1
            options.tracePropagationTargets = [
                InfoPlistConfig.apiBaseUrl.absoluteString
            ]
        }
        let firebaseOptions = FirebaseOptions(
            googleAppID: InfoPlistConfig.firebaseGoogleAppId,
            gcmSenderID: InfoPlistConfig.firebaseGcmSenderId
        )
        firebaseOptions.clientID = InfoPlistConfig.firebaseClientId
        firebaseOptions.apiKey = InfoPlistConfig.firebaseApiKey
        firebaseOptions.bundleID = InfoPlistConfig.firebaseBundleId
        firebaseOptions.projectID = InfoPlistConfig.firebaseProjectId
        firebaseOptions.storageBucket = InfoPlistConfig.firebaseStorageBucket
        FirebaseApp.configure(options: firebaseOptions)
        AppTheme.setUp()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        Logger.setup(
            logClients: [
                CrashlyticsLoggingClient.create(deviceId: DeviceInfo().deviceID(), minLevel: .error),
                SentryLoggingClient.create(deviceId: DeviceInfo().deviceID(), minLevel: .info),
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
