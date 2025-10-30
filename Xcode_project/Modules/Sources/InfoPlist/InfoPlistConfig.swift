import Logger
import Foundation
import Domain

public struct InfoPlistConfig {
    
    private let infoPlistReader = InfoPlistReader()
    
    public init() {}

    public var apiBaseUrl: URL {
        infoPlistReader.url(for: "API_BASE_URL", scheme: "API_SCHEME")!
    }
    public var sentryDsnUrl: URL {
        infoPlistReader.url(for: "SENTRY_DSN_URL", scheme: "SENTRY_DSN_SCHEME")!
    }
    public var supportEmail: String {
        infoPlistReader.string(for: "SUPPORT_EMAIL")!
    }
    public var webBaseUrl: URL {
        infoPlistReader.url(for: "WEB_BASE_URL", scheme: "WEB_SCHEME")!
    }
    public var appStoreId: String {
        infoPlistReader.string(for: "APPSTORE_ID")!
    }
    public var firebaseGoogleAppId: String {
        infoPlistReader.string(for: "FIREBASE_GOOGLE_APP_ID")!
    }
    public var firebaseGcmSenderId: String {
        infoPlistReader.string(for: "FIREBASE_GCM_SENDER_ID")!
    }
    public var firebaseClientId: String {
        infoPlistReader.string(for: "FIREBASE_CLIENT_ID")!
    }
    public var firebaseApiKey: String {
        infoPlistReader.string(for: "FIREBASE_API_KEY")!
    }
    public var firebaseBundleId: String {
        infoPlistReader.string(for: "FIREBASE_BUNDLE_ID")!
    }
    public var firebaseProjectId: String {
        infoPlistReader.string(for: "FIREBASE_PROJECT_ID")!
    }
    public var firebaseStorageBucket: String {
        infoPlistReader.string(for: "FIREBASE_STORAGE_BUCKET")!
    }

    public func logConfigurations() {
        Logger.debug(
            """
            🔹 API_BASE_URL: \(apiBaseUrl)\n
            🔹 SENTRY_DSN_URL: \(sentryDsnUrl)\n
            🔹 SUPPORT_EMAIL: \(supportEmail)\n
            🔹 WEB_BASE_URL: \(webBaseUrl)\n
            🔹 APPSTORE_ID: \(appStoreId)\n
            🔹 FIREBASE_GOOGLE_APP_ID: \(firebaseGoogleAppId)\n
            🔹 FIREBASE_GCM_SENDER_ID: \(firebaseGcmSenderId)\n
            🔹 FIREBASE_CLIENT_ID: \(firebaseClientId)\n
            🔹 FIREBASE_API_KEY: \(firebaseApiKey)\n
            🔹 FIREBASE_BUNDLE_ID: \(firebaseBundleId)\n
            🔹 FIREBASE_PROJECT_ID: \(firebaseProjectId)\n
            🔹 FIREBASE_STORAGE_BUCKET: \(firebaseStorageBucket)
            """
        )
    }
}
