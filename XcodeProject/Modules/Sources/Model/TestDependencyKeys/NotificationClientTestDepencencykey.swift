import ComposableArchitecture

public extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}

extension NotificationClient: TestDependencyKey {
    public static let previewValue = NotificationClient.noop
    public static let testValue = NotificationClient()
}
