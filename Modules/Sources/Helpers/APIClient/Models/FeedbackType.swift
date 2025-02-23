import Foundation
import Helpers

public enum FeedbackType: String, Codable, Equatable, RawRepresentable {
    case emoji, comment, thumpsUpThumpsDown, opinion, oneToTen
}

extension FeedbackType {
    init(_ input: String) {
        guard let feedbackType = FeedbackType(rawValue: input.lowercasingFirst()) else {
            fatalError("Could not parse \(input) into a valid FeedbackType")
        }
        self = feedbackType
    }
}
