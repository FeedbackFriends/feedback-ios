import ComposableArchitecture
import Foundation
import UIKit
import AppCore
import Model
import Logger
import Implementations
import OpenAPIURLSession
import OpenAPIRuntime
import OpenAPI
import FirebaseMessaging
import Utility

extension AuthClient: @retroactive DependencyKey {
    public static var liveValue:  AuthClient {
        return .live
    }
}

extension APIClient: @retroactive DependencyKey {
    public static var liveValue: APIClient {
        return .live(
            client: Client(
                serverURL: Config().apiBaseUrl,
                configuration: Configuration(),
                transport: URLSessionTransport(),
                middlewares: [
                    AuthorisationMiddleware(),
                    DelayMiddleware(),
                    DeviceIdHeaderMiddleware(deviceId: DeviceInfo().deviceID())
                ]
            ),
            provideFcmToken: {
                do {
                    return try await Messaging.messaging().token()
                } catch {
                    return nil
                }
            }
        )
    }
}

extension SystemClient: @retroactive DependencyKey {
    
    public static var liveValue: SystemClient {
        .live(
            webUrl: Config().webBaseUrl,
            appstoreId: Config().appStoreId,
            supportEmail: Config().supportEmail
        )
    }
}

extension NotificationClient: @retroactive DependencyKey {
    public static let liveValue = Self.live
}
