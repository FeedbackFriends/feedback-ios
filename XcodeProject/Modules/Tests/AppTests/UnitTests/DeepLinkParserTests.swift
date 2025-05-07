import Foundation

import Testing
@testable import AppCore

@MainActor
class DeepLinkParserTests {
    
    @Test
    func deepLinkJoinEvent() {
        let url = URL(string: "letsgrow://invite?pin_code=1234")!
        guard let deepLink = url.parseDeepLink() else {
            fatalError()
        }
        switch deepLink {
        case .joinEvent(let pinCode):
            #expect(pinCode == .init(value: "1234"))
        }
    }
    
    @Test
    func deepLinkEmpty() {
        let url = URL(string: "letsgrow://")!
        let deepLink = url.parseDeepLink()
        #expect(deepLink == nil)
    }
    
    @Test
    func deepLinkWrongScheme() {
        let url = URL(string: "wtf://")!
        let deepLink = url.parseDeepLink()
        #expect(deepLink == nil)
    }
}
