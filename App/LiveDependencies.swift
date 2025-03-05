import DependencyClients
import ComposableArchitecture
import Foundation
import DesignSystem
import Helpers
import UIKit
import DesignSystem
import Helpers

let isMock = false

var deviceId: String {
    let key = "deviceId"
    guard let deviceId = UserDefaults.standard.string(forKey: key) else {
        let generatedId = UUID().uuidString
        UserDefaults.standard.set(generatedId, forKey: key)
        return generatedId
    }
    return deviceId
}

@MainActor
func startApp() {
    Task {
        await registerFonts()
        setupTheme()
    }
}

extension AuthClient: @retroactive DependencyKey {
    public static var liveValue:  AuthClient {
        if isMock {
            return .mock
        }
        return .live
    }
}

extension APIClient: @retroactive DependencyKey {
    public static var liveValue: APIClient {
        if isMock {
            return .mock()
        }
        return .live(
            baseUrl: URL(string: "\(infoPlist.API_SCHEME)://\(infoPlist.API_BASE_URL)")!,
            deviceId: deviceId
        )
    }
}

extension SystemClient: @retroactive DependencyKey {
    
    public static var liveValue: SystemClient {
        .live(
            webUrl: "\(infoPlist.WEB_SCHEME)://\(infoPlist.WEB_BASE_URL)",
            appstoreId: infoPlist.APPSTORE_ID,
            supportEmail: infoPlist.SUPPORT_EMAIL
        )
    }
}
