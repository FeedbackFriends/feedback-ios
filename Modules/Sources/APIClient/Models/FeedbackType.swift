import Foundation
import Helpers

public enum FeedbackType: String, Codable, Equatable, RawRepresentable {
    case emoji, comment, thumpsUpThumpsDown, opinion, oneToTen
}

extension FeedbackType {
    init(_ input: String) {
        self = .init(rawValue: input.lowercasingFirst())!
    }
}
