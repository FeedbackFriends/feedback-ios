import ComposableArchitecture
import Foundation

public extension DependencyValues {
    var webURLClient: WebURLClient {
        get { self[WebURLClient.self] }
        set { self[WebURLClient.self] = newValue }
    }
}

extension WebURLClient: TestDependencyKey {
    public static let testValue = WebURLClient()
    public static let previewValue = WebURLClient.init(
        inviteUrl: { URL(string: "https://letsgrow.dk/invite/\($0)")! },
        privacyPolicyUrl: { URL(string: "https://letsgrow.dk/privacy-policy")! },
        appStoreReviewUrl: { URL(string: "https://appstore.review")! }
    )
}
