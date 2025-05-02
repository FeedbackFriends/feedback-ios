import ComposableArchitecture

public extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

extension AuthClient: TestDependencyKey {
    public static let previewValue = AuthClient.mock
    public static let testValue = AuthClient()
}


