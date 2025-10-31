import ComposableArchitecture
import Foundation

@DependencyClient
public struct SystemClient: Sendable {
    public var openAppSettings: @Sendable () async -> String = { "" }
    @DependencyEndpoint
    public var openEmail: @Sendable (_ subject: String, _ body: String) -> URL = { _, _ in URL(string: "")! }
    public var privacyPolicyUrl: @Sendable () -> URL = { URL(string: "")! }
    public var appStoreReviewUrl: @Sendable () -> URL = { URL(string: "")! }
    public var inviteUrl: @Sendable (String) -> URL? = { _ in nil }
}
