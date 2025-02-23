import Foundation
import OpenAPIURLSession
import Helpers

public struct EventInput: Equatable {
    public var title: String
    public var agenda: String?
    public var date: Date
    public var durationInMinutes: Int
    public var location: String?
    public var questions: [QuestionInput]
    
    public struct QuestionInput: Equatable, Hashable {
        
        public var questionText: String
        public var feedbackType: FeedbackType
        
        public init(questionText: String, feedbackType: FeedbackType) {
            self.questionText = questionText
            self.feedbackType = feedbackType
        }
    }
    
    public init(
        title: String = "",
        agenda: String? = nil,
        date: Date = Date().roundedUpcoming5Min(),
        durationInMinutes: Int = 30,
        location: String? = nil,
        questions: [QuestionInput] = []
    ) {
        self.title = title
        self.agenda = agenda
        self.date = date
        self.durationInMinutes = durationInMinutes
        self.location = location
        self.questions = questions
    }
}

public extension EventInput {
     init(
        _ managerEvent: ManagerEvent
    ) {
        self.init(
            title: managerEvent.title,
            agenda: managerEvent.agenda,
            date: managerEvent.date,
            durationInMinutes: managerEvent.durationInMinutes,
            location: managerEvent.location,
            questions: managerEvent.questions.map { .init(questionText: $0.questionText, feedbackType: .emoji) }
        )
    }
}


extension ManagerEvent {
    init(_ event: Components.Schemas.ManagerEventDto) {
        let feedbackSummary: FeedbackSummary? = event.feedbackSummary.map {
            FeedbackSummary(
                totalFeedback: Int($0.totalFeedback),
                verySadPercentage: $0.verySadPercentage,
                sadPercentage: $0.sadPercentage,
                happyPercentage: $0.happyPercentage,
                veryHappyPercentage: $0.veryHappyPercentage
            )
        }
        self.init(
            id: UUID(uuidString: event.id)!,
            title: event.title,
            agenda: event.agenda,
            date: event.date,
            durationInMinutes: Int(event.durationInMinutes),
            pinCode: event.pinCode ?? "Expired",
            location: event.location,
            feedbackSummary: feedbackSummary,
            questions: event.questions.map {
                ManagerQuestion(
                    id: UUID(uuidString: $0.id)!,
                    questionText: $0.questionText,
                    feedbackType: .init($0.feedbackType.rawValue),
                    feedback: $0.feedback?.map { Feedback($0) },
                    feedbackSummary: $0.feedbackSummary.map {
                        QuestionFeedbackSummary(
                            totalFeedback: Int($0.totalFeedback),
                            verySadCount: Int($0.verySadCount),
                            sadCount: Int($0.sadCount),
                            happyCount: Int($0.happyCount),
                            veryHappyCount: Int($0.veryHappyCount)
                        )
                    },
                    newFeedbackForQuestion: Int($0.newFeedbackForQuestion)
                )
            },
            newFeedbackForEvent: Int(event.newFeedbackForEvent),
            ownerInfo: .init(name: event.ownerInfo.name, email: event.ownerInfo.email, phoneNumber: event.ownerInfo.phoneNumber)
        )
    }
}

extension ParticipantEvent {
    init(_ event: Components.Schemas.ParticipantEventDto) {
        self.init(
            id: UUID(uuidString: event.id)!,
            title: event.title,
            agenda: event.agenda,
            date: event.date,
            pinCode: event.pinCode,
            location: event.location,
            durationInMinutes: Int(event.durationInMinutes),
            questions: event.questions.map {
                .init(
                    id: UUID(uuidString: $0.id)!,
                    questionText: $0.questionText,
                    feedbackType: FeedbackType($0.feedbackType.rawValue)
                )
            },
            feedbackSubmitted: event.feedbackSubmited,
            ownerInfo: .init(
                name: event.ownerInfo.email,
                email: event.ownerInfo.email,
                phoneNumber: event.ownerInfo.phoneNumber
            )
        )
    }
}

extension Components.Schemas.EventInput {
    init(_ event: EventInput) {
        self.init(
            title: event.title,
            agenda: event.agenda,
            date: event.date, 
            durationInMinutes: Int32(event.durationInMinutes),
            location: event.location, 
            questions: event.questions.map {
                .init(questionText: $0.questionText, feedbackType: .init(rawValue: $0.feedbackType.rawValue.capitalized)!)
            }
        )
    }
}
//
//extension Event {
//    init(_ event: Components.Schemas.Event) {
//        self.init(
//            id: event.id,
//            title: event.title,
//            agenda: event.agenda,
//            date: event.date,
//            durationInMinutes: Int(event.durationInMinutes),
//            location: event.location,
//            createdAt: event.createdAt
//        )
//    }
//}
