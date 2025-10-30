@testable import Domain
import Foundation
import Testing

@MainActor
class DeeplinkParserTests {
    
    @Test
    func deeplinkFromNotificationPayload_feedbackReceived() {
        let uuid = UUID()
        let userInfo: [AnyHashable: Any] = [
            "type": "FEEDBACK_RECEIVED",
            "eventId": uuid.uuidString
        ]
        let deeplink = Deeplink(notificationUserInfo: userInfo)
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
        let deeplink = Deeplink(notificationUserInfo: userInfo)
        #expect(deeplink == nil)
    }
    
    @Test
    func deeplinkFromNotificationPayload_invalidEventId() {
        let userInfo: [AnyHashable: Any] = [
            "type": "FEEDBACK_RECEIVED",
            "eventId": "not-a-uuid"
        ]
        let deeplink = Deeplink(notificationUserInfo: userInfo)
        #expect(deeplink == nil)
    }
    
    @Test
    func deeplinkFromNotificationPayload_unexpectedType() {
        let userInfo: [AnyHashable: Any] = [
            "type": "UNKNOWN_TYPE",
            "eventId": UUID().uuidString
        ]
        let deeplink = Deeplink(notificationUserInfo: userInfo)
        #expect(deeplink == nil)
    }
    
    @Test
    func deeplinkJoinEvent() {
        let url = URL(string: "letsgrow://invite?pin_code=1234")!
        guard let deeplink = Deeplink(url: url) else {
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
        let deeplink = Deeplink(url: url)
        #expect(deeplink == nil)
    }
    
    @Test
    func deeplinkWrongScheme() {
        let url = URL(string: "wtf://")!
        let deeplink = Deeplink(url: url)
        #expect(deeplink == nil)
    }
}
