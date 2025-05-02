import Foundation
import UIKit
import Helpers

public extension SystemClient {
    static func live(
        webUrl: URL,
        appstoreId: String,
        supportEmail: String
    ) -> SystemClient {
        
        return .init(
            setUserInterfaceStyle: { userInterfaceStyle in
                await MainActor.run {
                    guard let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene
                    else { return }
                    scene.keyWindow?.overrideUserInterfaceStyle = userInterfaceStyle
                }
            },
            openSettingsURLString: { UIApplication.openSettingsURLString },
            inviteUrl: { pinCode in
                webUrl.appendingPathComponent("invite").appendingPathComponent(pinCode.value)
            },
            privacyPolicyUrl: {
                webUrl.appendingPathComponent("privacy-policy/")
            },
            appleMailUrl: { subject, body in
                let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let mailtoString = "mailto:\(supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)"
                guard let url = URL(string: mailtoString) else {
                    fatalError("Could not create url with string: \(mailtoString)")
                }
                return url
            },
            appStoreReviewUrl: {
                let urlString = "https://apps.apple.com/app/id\(appstoreId)?action=write-review"
                guard let appStoreReviewUrl = URL(string: urlString)
                else {
                    fatalError("Could not create url with string: \(urlString)")
                }
                return appStoreReviewUrl
            }
        )
    }
}
