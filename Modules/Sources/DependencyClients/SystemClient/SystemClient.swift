import ComposableArchitecture
import Foundation
import UIKit

@DependencyClient
public struct SystemClient {
    public var setUserInterfaceStyle: @Sendable (UIUserInterfaceStyle) async -> Void
    public var hideKeyboard: @Sendable () async -> Void
    public var openSettingsURLString: @Sendable () async -> String = { "" }
    public var makeImpact: (_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> Void
    public var inviteUrl: (_ pinCode: String) -> URL = { _ in URL(string: "")! }
    public var privacyPolicyUrl: () -> URL = { URL(string: "")! }
    public var appleMailUrl: (_ subject: String, _ body: String) -> URL = { _, _ in URL(string: "")! }
    public var appStoreReviewUrl: () -> URL = { URL(string: "")! }
}
