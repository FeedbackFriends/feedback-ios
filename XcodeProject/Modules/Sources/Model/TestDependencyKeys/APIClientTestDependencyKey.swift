import ComposableArchitecture

public extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

extension APIClient: TestDependencyKey {
    public static let previewValue = APIClient.mock()
    public static let testValue = APIClient()
}
