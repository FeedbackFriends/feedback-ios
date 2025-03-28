import Helpers
import ComposableArchitecture
import Foundation
import DesignSystem
import Helpers
import UIKit
import DesignSystem
import Helpers
import LiveClients
import Logger

let isMock = Bool(infoPlist.MOCK_API)!

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
    setupTheme()
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

extension LogClient: @retroactive DependencyKey {
    public static let liveValue = logClient()
}

func logClient() -> LogClient {
    let logger = LogClient.live
    logger.addCrashlyticsClient(deviceId: deviceId, minLevel: .error)
    logger.addOSLogClient(subsystem: Bundle.main.bundleIdentifier!, category: "LoggingClient")
    return logger
}

