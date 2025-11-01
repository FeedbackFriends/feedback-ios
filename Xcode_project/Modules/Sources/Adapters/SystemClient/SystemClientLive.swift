import Foundation
import UIKit
import Domain

public extension SystemClient {
    static func live(
        supportEmail: String
    ) -> SystemClient {
        return .init(
            openAppSettings: { UIApplication.openSettingsURLString },
            openEmail: { subject, body in
                var components = URLComponents(string: "mailto:\(supportEmail)")!
                components.queryItems = [
                    URLQueryItem(name: "subject", value: subject),
                    URLQueryItem(name: "body", value: body)
                ]
                return components.url!
            }
        )
    }
}
