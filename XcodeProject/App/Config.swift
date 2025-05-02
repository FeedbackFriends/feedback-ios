import Foundation
import Utility

public let config = Config()

public struct Config {
    
    let plist: InfoPlist
    
    init(infoPlist: InfoPlist = .init()) {
        self.plist = infoPlist
    }
    
    var apiBaseUrl: URL {
        plist.url(for: "API_BASE_URL", scheme: "API_SCHEME")!
    }
    var webBaseUrl: URL {
        plist.url(for: "WEB_BASE_URL", scheme: "WEB_SCHEME")!
    }
    var supportEmail: String {
        plist.string(for: "SUPPORT_EMAIL")!
    }
    var appStoreId: String {
        plist.string(for: "APPSTORE_ID")!
    }
}
