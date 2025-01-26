import ComposableArchitecture

extension FirebaseClient: TestDependencyKey {
    #warning("Change to mock")
    public static var previewValue = FirebaseClient.failing
    public static let testValue = FirebaseClient.failing
}

public extension DependencyValues {
  var firebaseClient: FirebaseClient {
    get { self[FirebaseClient.self] }
    set { self[FirebaseClient.self] = newValue }
  }
}

