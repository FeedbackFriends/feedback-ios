import Foundation

import Testing
@testable import AppCore

@MainActor
class DeeplinkParserTests {
    
    #warning("Add notification tests as well")
    
    @Test
    func deeplinkJoinEvent() {
        let url = URL(string: "letsgrow://invite?pin_code=1234")!
        guard let deeplink = DeeplinkParser.fromUrl(url) else {
            fatalError()
        }
        switch deeplink {
        case .joinEvent(let pinCode):
            #expect(pinCode == .init(value: "1234"))
        case .managerEvent:
            fatalError()
        }
    }
    
    @Test
    func deeplinkEmpty() {
        let url = URL(string: "letsgrow://")!
        let deeplink = DeeplinkParser.fromUrl(url)
        #expect(deeplink == nil)
    }
    
    @Test
    func deeplinkWrongScheme() {
        let url = URL(string: "wtf://")!
        let deeplink = DeeplinkParser.fromUrl(url)
        #expect(deeplink == nil)
    }
}
