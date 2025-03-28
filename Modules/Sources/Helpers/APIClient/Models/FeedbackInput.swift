import Foundation

public struct FeedbackInput: Equatable, Sendable {
    public let type: FeedbackType2
    public let questionId: UUID
    public init(type: FeedbackType2, questionId: UUID) {
        self.type = type
        self.questionId = questionId
    }
}
