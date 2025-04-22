import Foundation
import OpenAPIRuntime
import IdentifiedCollections

public struct FeedbackSession: Equatable, Sendable {
    public let title: String
    public let agenda: String?
    public let questions: [ParticipantQuestion]
    public let ownerInfo: OwnerInfo
    public let pinCode: String
    public let date: Date
    public init(
        title: String,
        agenda: String?,
        questions: [ParticipantQuestion],
        ownerInfo: OwnerInfo,
        pinCode: String,
        date: Date
    ) {
        self.title = title
        self.agenda = agenda
        self.questions = questions
        self.ownerInfo = ownerInfo
        self.pinCode = pinCode
        self.date = date
    }
}
