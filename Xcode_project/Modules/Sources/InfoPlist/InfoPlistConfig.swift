import Logger
import Foundation

public enum InfoPlistConfig {
    
    public static var apiBaseUrl: URL {
        InfoPlist().url(for: "API_BASE_URL", scheme: "API_SCHEME")!
    }
    public static var sentryDsnUrl: URL {
        InfoPlist().url(for: "SENTRY_DSN_URL", scheme: "SENTRY_DSN_SCHEME")!
    }
    public static var supportEmail: String {
        InfoPlist().string(for: "SUPPORT_EMAIL")!
    }
    public static var webBaseUrl: URL {
        InfoPlist().url(for: "WEB_BASE_URL", scheme: "WEB_SCHEME")!
    }
    public static var appStoreId: String {
        InfoPlist().string(for: "APPSTORE_ID")!
    }
    public static var firebaseGoogleAppId: String {
        InfoPlist().string(for: "FIREBASE_GOOGLE_APP_ID")!
    }
    public static var firebaseGcmSenderId: String {
        InfoPlist().string(for: "FIREBASE_GCM_SENDER_ID")!
    }
    public static var firebaseClientId: String {
        InfoPlist().string(for: "FIREBASE_CLIENT_ID")!
    }
    public static var firebaseApiKey: String {
        InfoPlist().string(for: "FIREBASE_API_KEY")!
    }
    public static var firebaseBundleId: String {
        InfoPlist().string(for: "FIREBASE_BUNDLE_ID")!
    }
    public static var firebaseProjectId: String {
        InfoPlist().string(for: "FIREBASE_PROJECT_ID")!
    }
    public static var firebaseStorageBucket: String {
        InfoPlist().string(for: "FIREBASE_STORAGE_BUCKET")!
    }
    
    public static func logConfigurations() {
        Logger.debug(
            """
            🔹 API_BASE_URL: \(InfoPlistConfig.apiBaseUrl)\n
            🔹 SENTRY_DSN_URL: \(InfoPlistConfig.sentryDsnUrl)\n
            🔹 SUPPORT_EMAIL: \(InfoPlistConfig.supportEmail)\n
            🔹 WEB_BASE_URL: \(InfoPlistConfig.webBaseUrl)\n
            🔹 APPSTORE_ID: \(InfoPlistConfig.appStoreId)\n
            🔹 FIREBASE_GOOGLE_APP_ID: \(InfoPlistConfig.firebaseGoogleAppId)\n
            🔹 FIREBASE_GCM_SENDER_ID: \(InfoPlistConfig.firebaseGcmSenderId)\n
            🔹 FIREBASE_CLIENT_ID: \(InfoPlistConfig.firebaseClientId)\n
            🔹 FIREBASE_API_KEY: \(InfoPlistConfig.firebaseApiKey)\n
            🔹 FIREBASE_BUNDLE_ID: \(InfoPlistConfig.firebaseBundleId)\n
            🔹 FIREBASE_PROJECT_ID: \(InfoPlistConfig.firebaseProjectId)\n
            🔹 FIREBASE_STORAGE_BUCKET: \(InfoPlistConfig.firebaseStorageBucket)
            """
        )
    }
}
