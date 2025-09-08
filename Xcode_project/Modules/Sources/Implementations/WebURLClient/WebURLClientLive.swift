import Foundation
import UIKit
import Model
import Logger

public extension WebURLClient {
    static func live(webBaseUrl: URL, appStoreId: String) -> WebURLClient {
        return .init(
            inviteUrl: { pinCode in
                Logger.debug("Making invite URL for pinCode: \(pinCode.value)")
                return webBaseUrl
                    .appendingPathComponent("invite")
                    .appendingPathComponent(pinCode.value)
            },
            privacyPolicyUrl: {
                webBaseUrl.appendingPathComponent("privacy-policy/")
            },
            appStoreReviewUrl: {
                URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review")!
            }
        )
    }
}
