import ComposableArchitecture
import Foundation
import UIKit

@DependencyClient
public struct SystemClient: Sendable {
    public var setUserInterfaceStyle: @Sendable (UIUserInterfaceStyle) async -> Void
    public var openSettingsURLString: @Sendable () async -> String = { "" }
    @DependencyEndpoint
    public var inviteUrl: @Sendable (_ pinCode: PinCode) -> URL = { _ in URL(string: "")! }
    public var privacyPolicyUrl: @Sendable () -> URL = { URL(string: "")! }
    @DependencyEndpoint
    public var appleMailUrl: @Sendable (_ subject: String, _ body: String) -> URL = { _, _ in URL(string: "")! }
    public var appStoreReviewUrl: @Sendable () -> URL = { URL(string: "")! }
}
