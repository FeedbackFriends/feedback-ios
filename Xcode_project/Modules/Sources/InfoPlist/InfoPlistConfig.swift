import Logger
import Foundation

public struct InfoPlistConfig {
    
    public static var apiBaseUrl: URL {
        InfoPlistReader().url(for: "API_BASE_URL", scheme: "API_SCHEME")!
    }
    public static var sentryDsnUrl: URL {
        InfoPlistReader().url(for: "SENTRY_DSN_URL", scheme: "SENTRY_DSN_SCHEME")!
    }
    public static var supportEmail: String {
        InfoPlistReader().string(for: "SUPPORT_EMAIL")!
    }
    public static var webBaseUrl: URL {
        InfoPlistReader().url(for: "WEB_BASE_URL", scheme: "WEB_SCHEME")!
    }
    public static var appStoreId: String {
        InfoPlistReader().string(for: "APPSTORE_ID")!
    }
    public static var firebaseGoogleAppId: String {
        InfoPlistReader().string(for: "FIREBASE_GOOGLE_APP_ID")!
    }
    public static var firebaseGcmSenderId: String {
        InfoPlistReader().string(for: "FIREBASE_GCM_SENDER_ID")!
    }
    public static var firebaseClientId: String {
        InfoPlistReader().string(for: "FIREBASE_CLIENT_ID")!
    }
    public static var firebaseApiKey: String {
        InfoPlistReader().string(for: "FIREBASE_API_KEY")!
    }
    public static var firebaseBundleId: String {
        InfoPlistReader().string(for: "FIREBASE_BUNDLE_ID")!
    }
    public static var firebaseProjectId: String {
        InfoPlistReader().string(for: "FIREBASE_PROJECT_ID")!
    }
    public static var firebaseStorageBucket: String {
        InfoPlistReader().string(for: "FIREBASE_STORAGE_BUCKET")!
    }

    public static func logConfigurations() {
        Logger.debug(
            """
            🔹 API_BASE_URL: \(Self.apiBaseUrl)\n
            🔹 SENTRY_DSN_URL: \(Self.sentryDsnUrl)\n
            🔹 SUPPORT_EMAIL: \(Self.supportEmail)\n
            🔹 WEB_BASE_URL: \(Self.webBaseUrl)\n
            🔹 APPSTORE_ID: \(Self.appStoreId)\n
            🔹 FIREBASE_GOOGLE_APP_ID: \(Self.firebaseGoogleAppId)\n
            🔹 FIREBASE_GCM_SENDER_ID: \(Self.firebaseGcmSenderId)\n
            🔹 FIREBASE_CLIENT_ID: \(Self.firebaseClientId)\n
            🔹 FIREBASE_API_KEY: \(Self.firebaseApiKey)\n
            🔹 FIREBASE_BUNDLE_ID: \(Self.firebaseBundleId)\n
            🔹 FIREBASE_PROJECT_ID: \(Self.firebaseProjectId)\n
            🔹 FIREBASE_STORAGE_BUCKET: \(Self.firebaseStorageBucket)
            """
        )
    }
}
