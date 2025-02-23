import ComposableArchitecture

extension AuthClient: TestDependencyKey {
    public static var previewValue = AuthClient.mock
    public static let testValue = AuthClient()
}

public extension DependencyValues {
    var authClient: AuthClient {
    get { self[AuthClient.self] }
    set { self[AuthClient.self] = newValue }
  }
}
