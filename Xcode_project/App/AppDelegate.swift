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
                options.dsn = "https://1d3acbbfa16c39cb6544772448bb28d0@o4509912181899264.ingest.de.sentry.io/4509912183341136"
                options.debug = true // Enabled debug when first installing is always helpful
                // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
                // We recommend adjusting this value in production.
                options.tracesSampleRate = 1.0
            }
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

extension AppDelegate: UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		willPresent notification: UNNotification,
		withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
	) {
		completionHandler([.banner, .sound, .list])
	}
}
