import AppCore
import SwiftUI
import Model
import Foundation
import ComposableArchitecture
import DesignSystem
import Logger

@main
struct FeedbackMockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    var body: some Scene {
        WindowGroup {
            AppCoreView(
                store: appDelegate.intialStore
            )
            .task {
                Task {
                    try await Task.sleep(for: .seconds(1))
                    await appDelegate.mockAuthEngine.yield(.authenticated)
                }
            }
        }
    }
}


extension APIClient {
    static var mock: Self {
        return .init(
            deleteAccount: { () },
            updateAccount: { _, _, _ in },
            linkFCMTokenToAccount: { _ in },
            logout: {},
            getSession: { .mock() },
            startFeedbackSession: { _ in .mock },
            submitFeedback: { _, _ in true },
            createEvent: { _ in .mock() },
            updateEvent: { _, _ in .mock() },
            deleteEvent: { _ in },
            createAccount: { _ in .mock() },
            sessionChangedListener: { .never },
            joinEvent: { _ in },
            markEventAsSeen: { _ in },
            updateAccountRole: { _ in },
            getMockToken: { "" },
            getUpdatedSession: { .mock() },
            markActivityAsSeen: {}
        )
    }
}


actor MockAuthEngine {
    
    private var continuation: AsyncStream<UserState>.Continuation?
    
    func yield(_ state: UserState) {
        continuation?.yield(state)
    }
    
    func stream() -> AsyncStream<UserState> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }
}

extension AuthClient {
    static func mock(mockAuthEngine: MockAuthEngine) -> Self {
        return Self.init(
            signInAnonymously: {
                await mockAuthEngine.yield(.anonymous)
            },
            fetchCustomRole: { nil },
            googleLogin: {
                await mockAuthEngine.yield(.authenticated)
            },
            appleLogin: {
                await mockAuthEngine.yield(.authenticated)
            },
            logout: {
                await mockAuthEngine.yield(.loggedOut)
            },
            userStateChanged: {
                await mockAuthEngine.stream()
            }
        )
    }
}

extension SystemClient {
    static let mock = Self.init(
        setUserInterfaceStyle: { _ in },
        openSettingsURLString: { "" },
        inviteUrl: { URL(string: "https://letsgrow.dk/invite/\($0)")! },
        privacyPolicyUrl: { URL(string: "https://letsgrow.dk/privacy-policy")! },
        appleMailUrl: { _, _ in URL(string: "https://mail.url")! },
        appStoreReviewUrl: { URL(string: "https://appstore.url")! }
    )
}

extension NotificationClient {
    static let mock = Self.init(
        shouldPromptForAuthorization: { role in
            if role == nil {
                return false
            }
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            switch settings.authorizationStatus {
            case .notDetermined:
                return true
            default:
                return false
            }
        },
        requestAuthorization: {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [
                .alert,
                .badge,
                .sound
            ])
        },
        scheduleLocalNotification: { _, _, _, _, _ in },
        removeLocalPendingNotificationRequests: { _ in }
    )
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    let mockAuthEngine = MockAuthEngine()
    lazy var intialStore = Store(
        initialState: AppCore.State(),
        reducer: {
            AppCore()._printChanges()
        },
        withDependencies: {
            $0.apiClient = .mock
            $0.authClient = .mock(mockAuthEngine: self.mockAuthEngine)
            $0.systemClient = .mock
            $0.notificationClient = .mock
        }
    )
    
    /// On app launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppTheme.setUp()
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        Logger.setup(
            logClients: [
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

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
