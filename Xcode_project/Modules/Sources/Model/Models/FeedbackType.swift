import Foundation
import Utility

public enum FeedbackType: String, Codable, Equatable, RawRepresentable, Sendable {
    case emoji, comment, thumpsUpThumpsDown, opinion, oneToTen
}

extension FeedbackType {
    public init(_ input: String) {
        guard let feedbackType = FeedbackType(rawValue: input.lowercasingFirst()) else {
            fatalError("Could not parse \(input) into a valid FeedbackType")
        }
        self = feedbackType
    }
}
