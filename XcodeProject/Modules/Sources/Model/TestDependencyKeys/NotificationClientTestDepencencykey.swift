import ComposableArchitecture

public extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}

extension NotificationClient: TestDependencyKey {
    public static let previewValue = Self.init(
        shouldPromptForAuthorization: { _ in true },
        requestAuthorization: { true },
        scheduleLocalNotification: { _, _, _, _ , _ in },
        removeLocalPendingNotificationRequests: { _ in }
    )
    public static let testValue = NotificationClient()
}
