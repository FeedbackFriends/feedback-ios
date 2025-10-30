@testable import InfoPlist

import Foundation
import Testing

@MainActor
class InfoPlistReaderTests {
    
    @Test
    func stringValueReturnsCorrectValue() {
        let plist = InfoPlistReader(bundle: MockBundle(info: ["API_BASE_URL": "api.example.com"]))
        #expect(plist.string(for: "API_BASE_URL") == "api.example.com")
    }
    
    @Test
    func urlValueConstructsCorrectUrlFromHostAndScheme() {
        let plist = InfoPlistReader(bundle: MockBundle(info: [
            "WEB_BASE_URL": "example.com",
            "WEB_SCHEME": "https"
        ]))
        let expected = URL(string: "https://example.com")
        #expect(plist.url(for: "WEB_BASE_URL", scheme: "WEB_SCHEME") == expected)
    }
    
    @Test
    func rawRepresentableValueDecodesEnumSuccessfully() {
        enum Mode: String { case dev, prod }
        
        let plist = InfoPlistReader(bundle: MockBundle(info: ["MODE": "prod"]))
        #expect(plist.value(for: "MODE") as Mode? == .prod)
    }
    
    @Test
    func missingKeysReturnNilGracefully() {
        let plist = InfoPlistReader(bundle: MockBundle(info: [:]))
        #expect(plist.string(for: "MISSING_KEY") == nil)
        #expect(plist.url(for: "X", scheme: "Y") == nil)
        #expect(plist.value(for: "MISSING") as Int? == nil)
    }
}

final class MockBundle: Bundle, @unchecked Sendable {
    private let info: [String: Any]
    
    init(info: [String: Any]) {
        self.info = info
        super.init()
    }
    
    override func object(forInfoDictionaryKey key: String) -> Any? {
        info[key]
    }
}
