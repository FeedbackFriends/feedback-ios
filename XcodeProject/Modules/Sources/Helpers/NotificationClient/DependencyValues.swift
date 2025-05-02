import Dependencies

extension DependencyValues {
    public var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}

extension NotificationClient: DependencyKey {
    public static let liveValue = Self.live
    public static let previewValue = Self.noop
    public static let testValue = Self.noop
}
