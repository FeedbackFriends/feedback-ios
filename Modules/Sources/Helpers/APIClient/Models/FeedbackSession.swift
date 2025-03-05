import Foundation
import OpenAPIRuntime

public struct FeedbackSession: Equatable, Sendable {
    public let title: String
    public let agenda: String?
    public let questions: [ParticipantQuestion]
    public let ownerInfo: OwnerInfo
    public let pinCode: String
    public let date: Date
}

extension FeedbackSession {
    init(_ feedbackSession: Components.Schemas.FeedbackSessionDto, pinCode: String) {
        self.init(
            title: feedbackSession.title,
            agenda: feedbackSession.agenda,
            questions: feedbackSession.questions.map {
                ParticipantQuestion(
                    id: UUID(uuidString: $0.id)!,
                    questionText: $0.questionText,
                    feedbackType: .init($0.feedbackType.rawValue)
                )
            },
            ownerInfo: .init(
                name: feedbackSession.ownerInfo.name,
                email: feedbackSession.ownerInfo.email,
                phoneNumber: feedbackSession.ownerInfo.phoneNumber
            ),
            pinCode: pinCode,
            date: feedbackSession.date
        )
    }
}
