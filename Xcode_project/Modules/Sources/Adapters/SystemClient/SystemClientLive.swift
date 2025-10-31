import Foundation
import UIKit
import Domain

public extension SystemClient {
    static func live(
        supportEmail: String,
        webBaseUrl: URL,
        appStoreId: String
    ) -> SystemClient {
        
        let config = AppConfiguration(
            webBaseUrl: webBaseUrl,
            appStoreId: appStoreId,
            supportEmail: supportEmail
        )
        
        return .init(
            openAppSettings: { UIApplication.openSettingsURLString },
            openEmail: { subject, body in
                var components = URLComponents(string: "mailto:\(supportEmail)")!
                components.queryItems = [
                    URLQueryItem(name: "subject", value: subject),
                    URLQueryItem(name: "body", value: body)
                ]
                return components.url!
            },
            privacyPolicyUrl: {
                return config.privacyPolicyUrl
            },
            appStoreReviewUrl: {
                return config.appStoreReviewUrl
            },
            inviteUrl: { pinCode in
                return config.inviteUrl(pinCode: pinCode)
            }
        )
    }
}
