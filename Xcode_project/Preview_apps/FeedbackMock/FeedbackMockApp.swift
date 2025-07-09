import RootFeature
import SwiftUI
import Model
import Foundation
import ComposableArchitecture
import DesignSystem
import Logger
import Utility

@main
struct FeedbackMockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootFeatureView(
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
        let delay = 1
        return .init(
            deleteAccount: {
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            updateAccount: { _, _, _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            linkFCMTokenToAccount: { _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            logout: {
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            getSession: {
                try await Task.sleep(for: .seconds(delay))
                return .mock()
                
            },
            startFeedbackSession: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock
            },
            submitFeedback: { _, _ in
                try await Task.sleep(for: .seconds(delay))
                return true
            },
            createEvent: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            updateEvent: { _, _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            deleteEvent: { _ in },
            createAccount: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            sessionChangedListener: { .never },
            joinEvent: { _ in },
            markEventAsSeen: { _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            updateAccountRole: { _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            getMockToken: { "" },
            getUpdatedSession: {
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            markActivityAsSeen: {
                try await Task.sleep(for: .seconds(delay))
                return ()
            }
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
            fetchCustomRole: { .manager },
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
        openAppSettings: {
            UIApplication.openSettingsURLString
        },
        openEmail: { subject, body in
            var components = URLComponents(string: "mailto:nicolaidam96@gmail.com")!
            components.queryItems = [
                URLQueryItem(name: "subject", value: subject),
                URLQueryItem(name: "body", value: body)
            ]
            return components.url!
            
        }
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

extension WebURLClient {
    static let mock = Self.init(
        inviteUrl: { pinCode in
            URL(string: "https://letsgrow.dk/invite/\(pinCode)")!
        },
        privacyPolicyUrl: {
            URL(string: "https://letsgrow.dk/privacy-policy")!
        },
        appStoreReviewUrl: {
            URL(string: "https://letsgrow.dk/")!
        }
    )
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    let mockAuthEngine = MockAuthEngine()
    lazy var intialStore = Store(
        initialState: RootFeature.State(),
        reducer: {
            RootFeature()._printChanges()
        },
        withDependencies: {
            $0.apiClient = .mock
            $0.authClient = .mock(mockAuthEngine: self.mockAuthEngine)
            $0.systemClient = .mock
            $0.notificationClient = .mock
            $0.webURLClient = .mock
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

extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
