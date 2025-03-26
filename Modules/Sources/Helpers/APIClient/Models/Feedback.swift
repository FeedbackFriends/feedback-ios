import Foundation

public struct Feedback: Equatable, Identifiable, Sendable {
    
    public var id: UUID { UUID() }
    public let type: FeedbackType2
    public let questionId: UUID
    public var isNew: Bool
    
    public init(type: FeedbackType2, questionId: UUID, isNew: Bool) {
        self.type = type
        self.questionId = questionId
        self.isNew = isNew
    }
}

public enum FeedbackType2: Equatable, Sendable {
    case emoji(emoji: Emoji, comment: String?)
    case comment(comment: String)
    case thumpsUpThumpsDown(thumbsUpThumpsDown: ThumbsUpThumpsDown, comment: String?)
    case opinion(opinion: Opinion, comment: String?)
    case oneToTen(oneToTen: Int, comment: String?)
}

public enum Emoji: String, Equatable, Sendable, Codable {
    case verySad = "verySad"
    case sad = "sad"
    case happy = "happy"
    case veryHappy = "veryHappy"
}

public enum ThumbsUpThumpsDown: String, Equatable, Sendable, Codable {
    case up = "up"
    case down = "down"
}

public enum Opinion: String, Equatable, Sendable, Codable {
    case stronglyDisagree = "stronglyDisagree"
    case disagree = "disagree"
    case neutral = "neutral"
    case agree = "agree"
    case stronglyAgree = "stronglyAgree"
    case noOpinion = "noOpinion"
}
