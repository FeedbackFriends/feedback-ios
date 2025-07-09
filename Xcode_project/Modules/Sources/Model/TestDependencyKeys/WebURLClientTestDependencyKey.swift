import ComposableArchitecture
import Foundation

extension WebURLClient: TestDependencyKey {
    public static let testValue = WebURLClient()
    public static let previewValue = WebURLClient.init(
        inviteUrl: { URL(string: "https://letsgrow.dk/invite/\($0)")! },
        privacyPolicyUrl: { URL(string: "https://letsgrow.dk/privacy-policy")! },
        appStoreReviewUrl: { URL(string: "https://appstore.review")! }
    )
}
