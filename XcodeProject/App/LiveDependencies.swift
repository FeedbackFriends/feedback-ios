import ComposableArchitecture
import Foundation
import UIKit
import AppCore
import LiveClients
import Model
import Logger

var deviceId: String {
    let deviceIdKey = "iCloud.dk.nicolaidam.device-id"
    if let uuidString = NSUbiquitousKeyValueStore.default.string(forKey: deviceIdKey),
       let uuid = UUID(uuidString: uuidString) {
        return uuid.uuidString
    }
    let uuid = UUID()
    NSUbiquitousKeyValueStore.default.set(uuid.uuidString, forKey: deviceIdKey)
    return uuid.uuidString
}

extension AuthClient: @retroactive DependencyKey {
    public static var liveValue:  AuthClient {
        return .live
    }
}

extension APIClient: @retroactive DependencyKey {
    public static var liveValue: APIClient {
        return .live(
            baseUrl: config.apiBaseUrl,
            deviceId: deviceId
        )
    }
}

extension SystemClient: @retroactive DependencyKey {
    
    public static var liveValue: SystemClient {
        .live(
            webUrl: config.webBaseUrl,
            appstoreId: config.appStoreId,
            supportEmail: config.supportEmail
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

extension NotificationClient: @retroactive DependencyKey {
    public static let liveValue = Self.live
}
