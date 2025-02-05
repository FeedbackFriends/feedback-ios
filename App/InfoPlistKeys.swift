import Foundation

// swiftlint:disable identifier_name
struct InfoPlistKeys {
    let COMPILER_FLAG: CompilerFlag
    let GOOGLE_SERVICE_PLIST: String
    let MOCK_API: Bool
    let API_BASE_URL: String
    let API_SCHEME: String
    let WEB_BASE_URL: String
    let WEB_SCHEME: String
}
public enum CompilerFlag: String {
    case dev
    case mock
    case release
    case test
}
// swiftlint:enable identifier_name

let infoPlist = Bundle.main.infoPlist(withKeys: InfoPlistKeys.self).unsafe
