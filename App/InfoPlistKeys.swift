import Foundation

// swiftlint:disable identifier_name
struct InfoPlistKeys {
    let COMPILER_FLAG: CompilerFlag
    let GOOGLE_SERVICE_PLIST: String
    let MOCK_API: String
    let API_BASE_URL: String
    let API_SCHEME: String
    let WEB_BASE_URL: String
    let WEB_SCHEME: String
    let SUPPORT_EMAIL: String
    let APPSTORE_ID: String
}
enum CompilerFlag: String {
    case dev
    case mock
    case release
    case test
}
// swiftlint:enable identifier_name

let infoPlist = Bundle.main.infoPlist(withKeys: InfoPlistKeys.self).unsafe

