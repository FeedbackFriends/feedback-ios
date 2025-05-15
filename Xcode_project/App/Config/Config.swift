import Foundation
import Utility

struct Config {
    
    let infoPlist: InfoPlist = .init()
    
    var apiBaseUrl: URL {
        infoPlist.url(for: "API_BASE_URL", scheme: "API_SCHEME")!
    }
    var webBaseUrl: URL {
        infoPlist.url(for: "WEB_BASE_URL", scheme: "WEB_SCHEME")!
    }
    var supportEmail: String {
        infoPlist.string(for: "SUPPORT_EMAIL")!
    }
    var appStoreId: String {
        infoPlist.string(for: "APPSTORE_ID")!
    }
}
