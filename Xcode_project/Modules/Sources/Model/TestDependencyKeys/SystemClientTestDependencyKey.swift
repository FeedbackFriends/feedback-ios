import ComposableArchitecture
import Foundation

public extension DependencyValues {
    var systemClient: SystemClient {
        get { self[SystemClient.self] }
        set { self[SystemClient.self] = newValue }
    }
}

extension SystemClient: TestDependencyKey {
    public static let testValue = SystemClient.mock
    public static let previewValue = SystemClient.mock
}

private extension SystemClient {
    static let mock = Self.init(
        setUserInterfaceStyle: { _ in },
        openSettingsURLString: { URL.mock.absoluteString },
        inviteUrl: { _ in .mock },
        privacyPolicyUrl: { .mock },
        appleMailUrl: { _ , _ in .mock },
        appStoreReviewUrl: { .mock }
    )
}

private extension URL {
    static let mock = Self(string: "https://letsgrow.dk")!
}
