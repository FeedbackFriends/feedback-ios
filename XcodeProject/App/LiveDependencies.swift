import ComposableArchitecture
import Foundation
import UIKit
import AppCore
import APIClient
import Model
import Logger
import OpenAPIURLSession
import OpenAPIRuntime
import SystemClient
import NotificationClient
import OpenAPI
import Authentication
import Crashlytics
import FirebaseMessaging

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
        return .api(
            client: Client(
                serverURL: config.apiBaseUrl,
                configuration: Configuration(),
                transport: URLSessionTransport(),
                middlewares: [
                    AuthorisationMiddleware(),
                    DelayMiddleware(),
                    DeviceIdHeaderMiddleware(deviceId: deviceId)
                ]
            ),
            fcmToken: {
                try await Messaging.messaging().token()
            }
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

extension NotificationClient: @retroactive DependencyKey {
    public static let liveValue = Self.live
}
