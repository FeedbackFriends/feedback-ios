import ComposableArchitecture
import Foundation

public extension DependencyValues {
    var systemClient: SystemClient {
        get { self[SystemClient.self] }
        set { self[SystemClient.self] = newValue }
    }
}

extension SystemClient: TestDependencyKey {
    public static let testValue = SystemClient()
    public static let previewValue = Self.init(
        setUserInterfaceStyle: { _ in },
        openSettingsURLString: { "https://letsgrow.dk" },
        inviteUrl: { _ in URL(string: "https://letsgrow.dk")! },
        privacyPolicyUrl: { URL(string: "https://letsgrow.dk")! },
        appleMailUrl: { _ , _ in URL(string: "https://letsgrow.dk")! },
        appStoreReviewUrl: { URL(string: "https://letsgrow.dk")! }
    )
}
