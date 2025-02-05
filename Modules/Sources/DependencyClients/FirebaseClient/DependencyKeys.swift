import ComposableArchitecture

extension FirebaseClient: TestDependencyKey {
    public static var previewValue = FirebaseClient.mock
    public static let testValue = FirebaseClient.mock
}

public extension DependencyValues {
  var firebaseClient: FirebaseClient {
    get { self[FirebaseClient.self] }
    set { self[FirebaseClient.self] = newValue }
  }
}

