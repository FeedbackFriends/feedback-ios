import Foundation

public struct AppConfiguration: Sendable {
    let webBaseUrl: URL
    let appStoreId: String
    let supportEmail: String
    
    public init(
        webBaseUrl: URL,
        appStoreId: String,
        supportEmail: String
    ) {
        self.webBaseUrl = webBaseUrl
        self.appStoreId = appStoreId
        self.supportEmail = supportEmail
    }
    
    public var privacyPolicyUrl: URL { AppWebURLProvider.privacyPolicy(forBaseUrl: webBaseUrl) }
    
    public var appStoreReviewUrl: URL { AppWebURLProvider.appStoreReview(forAppStoreId: appStoreId) }
    
    public func inviteUrl(pinCode: String) -> URL? {
        AppWebURLProvider.invite(forPinCode: pinCode, baseUrl: webBaseUrl)
    }
}
