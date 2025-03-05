import ComposableArchitecture

public extension DependencyValues {
    var systemClient: SystemClient {
        get { self[SystemClient.self] }
        set { self[SystemClient.self] = newValue }
    }
}

extension SystemClient: TestDependencyKey {
    public static let previewValue = SystemClient.noop
    public static let testValue = Self()
}
