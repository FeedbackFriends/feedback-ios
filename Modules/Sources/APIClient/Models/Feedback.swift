import Helpers
import Foundation

public struct Feedback: Equatable, Identifiable {
    
    public var id: UUID { questionId }
    public let type: FeedbackType2
    public let questionId: UUID
    public var isNew: Bool
    
    public init(type: FeedbackType2, questionId: UUID, isNew: Bool) {
        self.type = type
        self.questionId = questionId
        self.isNew = isNew
    }
}

public enum FeedbackType2: Equatable {
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

extension Feedback {
    init(_ feedback: Components.Schemas.FeedbackEntity) {
        switch feedback.feedbackType {
        case .Emoji:
            
            self = .init(
                type: .emoji(
                    emoji: .init(rawValue: feedback.emoji!.rawValue.lowercased())!,
                    comment: feedback.comment
                ),
                questionId: UUID(uuidString: feedback.questionId)!,
                isNew: feedback.isNew
            )
        case .Comment:
            self = .init(
                type: .comment(comment: feedback.comment!),
                questionId: UUID(uuidString: feedback.questionId)!,
                isNew: feedback.isNew
            )
        case .ThumpsUpThumpsDown:
            fatalError()
        case .OneToTen:
            fatalError()
        case .Opinion:
            fatalError()
        }
    }
}

extension Components.Schemas.FeedbackInput {
    init(_ feedback: Feedback) {
        switch feedback.type {
        case .emoji(emoji: let emoji, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                emoji: .init(input: emoji),
                questionId: feedback.questionId.uuidString,
                feedbackType: .Emoji
            )
        case .comment(comment: let comment):
            self.init(
                comment: comment,
                questionId: feedback.questionId.uuidString,
                feedbackType: .Comment
            )
        case .thumpsUpThumpsDown(thumbsUpThumpsDown: let thumbsUpThumpsDown, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                thumbsUpThumpsDown: .init(input: thumbsUpThumpsDown),
                questionId: feedback.questionId.uuidString,
                feedbackType: .ThumpsUpThumpsDown
            )
        case .opinion(opinion: let opinion, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                opinion: .init(input: opinion),
                questionId: feedback.questionId.uuidString,
                feedbackType: .Opinion
            )
        case .oneToTen(oneToTen: let oneToTen, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                oneToTen: Int32(oneToTen),
                questionId: feedback.questionId.uuidString,
                feedbackType: .OneToTen
            )
        }
    }
}

extension Components.Schemas.FeedbackInput.thumbsUpThumpsDownPayload {
    init(input: ThumbsUpThumpsDown) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

extension Components.Schemas.FeedbackInput.emojiPayload {
    init(input: Emoji) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

extension Components.Schemas.FeedbackInput.opinionPayload {
    init(input: Opinion) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

