import Foundation
import Model

public enum DeepLink {
    case joinEvent(pinCodeInput: PinCodeInput)
}

struct DeepLinkParser {
    public static func parse(_ url: URL) -> DeepLink? {
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
}

public extension URL {
    func parseDeepLink() -> DeepLink? {
        return DeepLinkParser.parse(self)
    }
}
