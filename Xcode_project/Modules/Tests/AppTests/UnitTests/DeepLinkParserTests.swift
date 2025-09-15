import Foundation

import Testing
@testable import RootFeature

@MainActor
class DeeplinkParserTests {
    
    @Test
    func deeplinkFromNotificationPayload_feedbackReceived() {
        let uuid = UUID()
        let userInfo: [AnyHashable: Any] = [
            "type": "FEEDBACK_RECEIVED",
            "eventId": uuid.uuidString
        ]
        let deeplink = DeeplinkParser.fromNotificationPayload(userInfo)
        switch deeplink {
        case .managerEvent(let id):
            #expect(id == uuid)
        default:
            fatalError("Expected .managerEvent")
        }
    }
    
    @Test
    func deeplinkFromNotificationPayload_missingType() {
        let userInfo: [AnyHashable: Any] = [
            "eventId": UUID().uuidString
        ]
        let deeplink = DeeplinkParser.fromNotificationPayload(userInfo)
        #expect(deeplink == nil)
    }
    
    @Test
    func deeplinkFromNotificationPayload_invalidEventId() {
        let userInfo: [AnyHashable: Any] = [
            "type": "FEEDBACK_RECEIVED",
            "eventId": "not-a-uuid"
        ]
        let deeplink = DeeplinkParser.fromNotificationPayload(userInfo)
        #expect(deeplink == nil)
    }
    
    @Test
    func deeplinkFromNotificationPayload_unexpectedType() {
        let userInfo: [AnyHashable: Any] = [
            "type": "UNKNOWN_TYPE",
            "eventId": UUID().uuidString
        ]
        let deeplink = DeeplinkParser.fromNotificationPayload(userInfo)
        #expect(deeplink == nil)
    }
    
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

@testable import Domain
@testable import Adapters
//
// @MainActor
// class SystemClientUrlGenerationTests {
//    
//    @Test
//    func testInviteUrlGeneration() {
//        let baseUrl = URL(string: "https://letsgrow.com")!
//        let appstoreId = "123456789"
//        let supportEmail = "support@example.com"
//        let systemClient: SystemClient = .live(supportEmail: "support@email.dk")
//        
//        let pinCode = PinCode(value: "2344")
//        let inviteUrl = systemClient.inviteUrl(pinCode)
//        #expect(inviteUrl.absoluteString == "https://letsgrow.com/invite/2344")
//    }
//    
//    @Test
//    func testPrivacyPolicyUrlGeneration() {
//        let baseUrl = URL(string: "https://letsgrow.com")!
//        let systemClient: SystemClient = .live(supportEmail: "support@email.dk")
//        
//        let url = systemClient.privacyPolicyUrl()
//        #expect(url.absoluteString == "https://letsgrow.com/privacy-policy/")
//    }
//    
//    @Test
//    func testAppStoreReviewUrlGeneration() {
//        let appstoreId = "987654321"
//        let systemClient: SystemClient = .live(supportEmail: "support@email.dk")
//        let url = systemClient.appStoreReviewUrl()
//        #expect(url.absoluteString == "https://apps.apple.com/app/id987654321?action=write-review")
//    }
//    
// }
