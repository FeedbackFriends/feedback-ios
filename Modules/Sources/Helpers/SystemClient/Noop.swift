import Foundation

extension SystemClient {
    static let noop = Self.init(
        setUserInterfaceStyle: { _ in },
        hideKeyboard: {}, 
        openSettingsURLString: { "https://letsgrow.dk" },
        inviteUrl: { _ in URL(string: "https://letsgrow.dk")! },
        privacyPolicyUrl: { URL(string: "https://letsgrow.dk")! },
        appleMailUrl: { _ , _ in URL(string: "https://letsgrow.dk")! },
        appStoreReviewUrl: { URL(string: "https://letsgrow.dk")! }
    )
}
