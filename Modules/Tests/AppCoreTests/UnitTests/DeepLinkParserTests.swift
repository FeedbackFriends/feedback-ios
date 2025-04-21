import Foundation

import Testing
@testable import Helpers

@MainActor
class DeepLinkParserTests {
    
    @Test
    func deepLink_joinEvent() {
        let url = URL(string: "letsgrow://invite?pin_code=123456")!
        guard let deepLink = DeepLinkParser.parse(url) else {
            fatalError()
        }
        switch deepLink {
        case .joinEvent(let pinCode):
            #expect(pinCode == "123456")
        }
    }
    
    @Test
    func deepLink_empty() {
        let url = URL(string: "letsgrow://")!
        let deepLink = DeepLinkParser.parse(url)
        #expect(deepLink == nil)
    }
    
    @Test
    func deepLink_wrongScheme() {
        let url = URL(string: "wtf://")!
        let deepLink = DeepLinkParser.parse(url)
        #expect(deepLink == nil)
    }
}
