import NotificationCenter
import Foundation
import Model
import Logger

public enum Deeplink: Equatable {
    case joinEvent(pinCodeInput: PinCodeInput)
    case managerEvent(id: UUID)
}

public enum DeeplinkParser {
    public static func fromUrl(_ url: URL) -> Deeplink? {
        guard
            url.scheme == "letsgrow",
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        switch (comps.host, comps.queryItems) {
        case ("invite", let items?):
            if let pinCodeInput = items.first(where: { $0.name=="pin_code" })?.value {
                return .joinEvent(pinCodeInput: .init(value: pinCodeInput))
            }
            return nil
        default:
            return nil
        }
    }
    public static func fromNotificationPayload(_ userInfo: [AnyHashable: Any]) -> Deeplink? {
        guard let type = userInfo["type"] as? String else {
            Logger.log(.error, "Failed to parse type from notification payload")
            return nil
        }
        
        switch type {
        case "FEEDBACK_RECEIVED":
            guard let eventIdString = userInfo["eventId"] as? String,
                  let eventId = UUID(uuidString: eventIdString) else {
                Logger.log(.error, "Failed to parse eventId from notification payload")
                return nil
            }
            return .managerEvent(id: eventId)
            
        default:
            Logger.log(.error, "Unexpected notification type \(type)")
            return nil
        }
    }
}
