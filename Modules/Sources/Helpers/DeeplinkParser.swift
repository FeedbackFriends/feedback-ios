import Foundation

public enum DeepLink {
    case joinEvent(pinCode: String)
}

public struct DeepLinkParser {
    public static func parse(_ url: URL) -> DeepLink? {
        guard
            url.scheme == "letsgrow",
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        switch (comps.host, comps.queryItems) {
        case ("invite", let items?):
            if let pinCode = items.first(where: { $0.name=="pin_code" })?.value {
                return .joinEvent(pinCode: pinCode)
            }
            return nil
        default:
            return nil
        }
    }
}
