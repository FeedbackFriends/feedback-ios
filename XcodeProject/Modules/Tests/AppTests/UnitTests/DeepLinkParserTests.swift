import Foundation

import Testing
@testable import AppCore

@MainActor
class DeeplinkParserTests {
    
    @Test
    func deeplinkJoinEvent() {
        let url = URL(string: "letsgrow://invite?pin_code=1234")!
        guard let deeplink = url.parseDeeplink() else {
            fatalError()
        }
        switch deeplink {
        case .joinEvent(let pinCode):
            #expect(pinCode == .init(value: "1234"))
        }
    }
    
    @Test
    func deeplinkEmpty() {
        let url = URL(string: "letsgrow://")!
        let deeplink = url.parseDeeplink()
        #expect(deeplink == nil)
    }
    
    @Test
    func deeplinkWrongScheme() {
        let url = URL(string: "wtf://")!
        let deeplink = url.parseDeeplink()
        #expect(deeplink == nil)
    }
}
