import Foundation

extension SystemClient {
    static let noop = Self.init(
        setUserInterfaceStyle: { _ in },
        hideKeyboard: {}, 
        openSettingsURLString: { "" },
        inviteUrl: { _ in URL(string: "")! },
        privacyPolicyUrl: { URL(string: "")! },
        appleMailUrl: { _ , _ in URL(string: "")! },
        appStoreReviewUrl: { URL(string: "")! }
    )
}
