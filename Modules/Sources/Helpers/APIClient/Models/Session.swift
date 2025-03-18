import Foundation
import ComposableArchitecture

public struct Session: Equatable, Sendable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var userType: UserType
    public var role: Role?
    public init(participantEvents: IdentifiedArrayOf<ParticipantEvent>, userType: UserType, role: Role? = nil) {
        self.participantEvents = participantEvents
        self.userType = userType
        self.role = role
    }
}

public enum UserType: Equatable, Sendable {
    case manager(managerData: ManagerData, accountInfo: AccountInfo)
    case participant(accountInfo: AccountInfo)
    case anonymoous
    public var role: Role? {
        switch self {
        case .manager:
            return Role.organizer
        case .participant:
            return Role.participant
        case .anonymoous:
            return nil
        }
    }
}

public struct AccountInfo: Equatable, Sendable {
    public let name: String?
    public let email: String?
    public let phoneNumber: String?
    public init(name: String?, email: String?, phoneNumber: String?) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }
}

public struct ParticipantEvent: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let agenda: String?
    public let date: Date
    public let pinCode: String
    public let location: String?
    public let durationInMinutes: Int
    public let questions: [ParticipantQuestion]
    public let feedbackSubmitted: Bool
    public let ownerInfo: OwnerInfo
    public let recentlyJoined: Bool
    
    public init(
        id: UUID,
        title: String,
        agenda: String?,
        date: Date,
        pinCode: String,
        location: String?,
        durationInMinutes: Int,
        questions: [ParticipantQuestion],
        feedbackSubmitted: Bool,
        ownerInfo: OwnerInfo,
        recentlyJoined: Bool
    ) {
        self.id = id
        self.title = title
        self.agenda = agenda
        self.date = date
        self.pinCode = pinCode
        self.location = location
        self.durationInMinutes = durationInMinutes
        self.questions = questions
        self.feedbackSubmitted = feedbackSubmitted
        self.ownerInfo = ownerInfo
        self.recentlyJoined = recentlyJoined
    }
}

public struct OwnerInfo: Equatable, Sendable {
    public let name: String?
    public let email: String?
    public let phoneNumber: String?
    public init(name: String?, email: String?, phoneNumber: String?) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }
}
public struct ParticipantQuestion: Equatable, Sendable {
    public let id: UUID
    public let questionText: String
    public let feedbackType: FeedbackType
    public init(id: UUID, questionText: String, feedbackType: FeedbackType) {
        self.id = id
        self.questionText = questionText
        self.feedbackType = feedbackType
    }
}

public struct FeedbackSummary: Equatable, Sendable {

    public let totalFeedback: Int
    public let verySadPercentage: Double
    public let sadPercentage: Double
    public let happyPercentage: Double
    public let veryHappyPercentage: Double
    
    public init(
        totalFeedback: Int,
        verySadPercentage: Double,
        sadPercentage: Double,
        happyPercentage: Double,
        veryHappyPercentage: Double
    ) {
        self.totalFeedback = totalFeedback
        self.verySadPercentage = verySadPercentage
        self.sadPercentage = sadPercentage
        self.happyPercentage = happyPercentage
        self.veryHappyPercentage = veryHappyPercentage
    }
}

public struct QuestionFeedbackSummary: Equatable, Sendable {
    public let totalFeedback: Int
    public let verySadCount: Int
    public let sadCount: Int
    public let happyCount: Int
    public let veryHappyCount: Int
    
    public init(totalFeedback: Int, verySadCount: Int, sadCount: Int, happyCount: Int, veryHappyCount: Int) {
        self.totalFeedback = totalFeedback
        self.verySadCount = verySadCount
        self.sadCount = sadCount
        self.happyCount = happyCount
        self.veryHappyCount = veryHappyCount
    }
}

public struct ManagerQuestion: Equatable, Hashable, Sendable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public let id: UUID
    public let questionText: String
    public let feedbackType: FeedbackType
    public var feedback: [Feedback]?
    public let feedbackSummary: QuestionFeedbackSummary?
    public var newFeedbackForQuestion: Int
    
    public init(
        id: UUID,
        questionText: String,
        feedbackType: FeedbackType,
        feedback: [Feedback]? = nil,
        feedbackSummary: QuestionFeedbackSummary?,
        newFeedbackForQuestion: Int
    ) {
        self.id = id
        self.questionText = questionText
        self.feedbackType = feedbackType
        self.feedback = feedback
        self.feedbackSummary = feedbackSummary
        self.newFeedbackForQuestion = newFeedbackForQuestion
    }
}

public struct ManagerEvent: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var agenda: String?
    public var date: Date
    public var formattedDate: String {
        if Calendar.current.dateComponents([.minute], from: date, to: end).minute == 1440 {
            return "\(date.dateAndYear()) - All day"
        } else if Calendar.current.isDate(date, inSameDayAs: end) {
            return "\(date.dateAndYear()) at \(date.timeFormatted())-\(end.timeFormatted())"
        } else {
            return "\(date.dateAndYear()) \(end.timeFormatted()) to \(end.formatted(.dateTime.day())) \(end.formatted(.dateTime.month())) \(end.timeFormatted())"
        }
    }
    public var durationInMinutes: Int
    public let pinCode: String
    public var location : String?
    public let feedbackSummary: FeedbackSummary?
    public var questions: [ManagerQuestion]
    public var newFeedbackForEvent: Int
    public var end: Date {
        date + TimeInterval(durationInMinutes*60)
    }
    public let ownerInfo: OwnerInfo
    
    public init(
        id: UUID,
        title: String,
        agenda: String? = nil,
        date: Date,
        durationInMinutes: Int,
        pinCode: String,
        location: String? = nil,
        feedbackSummary: FeedbackSummary?,
        questions: [ManagerQuestion],
        newFeedbackForEvent: Int,
        ownerInfo: OwnerInfo
    ) {
        self.id = id
        self.title = title
        self.agenda = agenda
        self.date = date
        self.durationInMinutes = durationInMinutes
        self.pinCode = pinCode
        self.location = location
        self.feedbackSummary = feedbackSummary
        self.questions = questions
        self.newFeedbackForEvent = newFeedbackForEvent
        self.ownerInfo = ownerInfo
    }
}

public struct ManagerData: Equatable, Sendable {
    public var managerEvents: IdentifiedArrayOf<ManagerEvent>
    public init(managerEvents: IdentifiedArrayOf<ManagerEvent>) {
        self.managerEvents = managerEvents
    }
}

public extension Session {
    
    mutating func updateOrAppendManagerEvent(_ event: ManagerEvent) {
        guard case let .manager(managerData: managerData, accountInfo: accountInfo) = self.userType else { return }
        var mutableManagerData = managerData
        mutableManagerData.managerEvents.updateOrAppend(event)
        self.userType = .manager(managerData: mutableManagerData, accountInfo: accountInfo)
    }
    
    mutating func updateOrAppendParticipantEvent(_ event: ParticipantEvent) {
        participantEvents.updateOrAppend(event)
    }
    
    mutating func updateParticipantEvent(_ event: ParticipantEvent) {
        if let index = participantEvents.firstIndex(of: event) {
            participantEvents[index] = event
        }
    }
    
    mutating func deleteEvent(_ id: UUID) {
        guard case let .manager(managerData: managerData, accountInfo: accountInfo) = self.userType else { return }
        var mutableManagerData = managerData
        mutableManagerData.managerEvents.remove(id: id)
        self.userType = .manager(managerData: mutableManagerData, accountInfo: accountInfo)
    }
    
    func getManagerEventId(_ id: UUID) -> ManagerEvent {
        guard case let .manager(managerData: managerData, accountInfo: _) = self.userType else { fatalError() }
        return managerData.managerEvents[id: id]!
    }
    mutating func resetNewFeedbackForEvent(eventId: UUID) {
        guard case let .manager(managerData, accountInfo) = self.userType else { return }
        
        var mutableManagerData = managerData
        guard var event = mutableManagerData.managerEvents[id: eventId] else { return }
        
        // Reset event-level feedback
        event.newFeedbackForEvent = 0
        
        // Reset question-level feedback and feedback properties
        event.questions = event.questions.map { question in
            var updatedQuestion = question
            updatedQuestion.newFeedbackForQuestion = 0
            
            updatedQuestion.feedback = updatedQuestion.feedback?.map { feedback in
                var updatedFeedback = feedback
                updatedFeedback.isNew = false
                return updatedFeedback
            }
            
            return updatedQuestion
        }
        
        mutableManagerData.managerEvents[id: eventId] = event
        self.userType = .manager(managerData: mutableManagerData, accountInfo: accountInfo)
    }
    
    mutating func updateAccount(name: String?, email: String?, phoneNumber: String?) {
        let updatedAccountInfo: AccountInfo = AccountInfo(
            name: name,
            email: email,
            phoneNumber: phoneNumber
        )
        switch self.userType {
        case .manager(managerData: let managerData, accountInfo: _):
            self.userType = .manager(managerData: managerData, accountInfo: updatedAccountInfo)
        case .participant(accountInfo: _):
            self.userType = .participant(accountInfo: updatedAccountInfo)
        case .anonymoous:
            return
        }
    }
}
