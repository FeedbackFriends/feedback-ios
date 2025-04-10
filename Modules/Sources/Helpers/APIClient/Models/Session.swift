import Foundation
import ComposableArchitecture

public struct ManagerSession: Equatable, Sendable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var managerData: ManagerData
    public var accountInfo: AccountInfo
}

public struct ParticipantSession: Equatable, Sendable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var accountInfo: AccountInfo
}

public struct AnonymousSession: Equatable, Sendable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
}

public struct NewSession: Equatable, Sendable {
    
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var managerData: ManagerData?
    public var accountInfo: AccountInfo
    public var role: Role?
    
    public init(
        participantEvents: IdentifiedArrayOf<ParticipantEvent>,
        managerData: ManagerData? = nil,
        accountInfo: AccountInfo,
        role: Role? = nil
    ) {
        self.participantEvents = participantEvents
        self.managerData = managerData
        self.accountInfo = accountInfo
        self.role = role
    }
    
    public enum Account: Equatable, Sendable {
        case manager(ManagerSession)
        case participant(ParticipantSession)
        case anonymous(AnonymousSession)
    }
    
    public var account: Account {
        switch role {
        case .participant:
            return .participant(
                .init(
                    participantEvents: self.participantEvents,
                    accountInfo: accountInfo
                )
            )
        case .manager:
            return .manager(
                .init(
                    participantEvents: self.participantEvents,
                    managerData: managerData!,
                    accountInfo: accountInfo
                )
            )
        case nil:
            return .anonymous(.init(participantEvents: self.participantEvents))
        }
    }
    
    public var activity: Activity {
        switch self.account {
        case .manager(let managerSession):
            return managerSession.managerData.activity
        case .participant(_):
            return .init(items: [], unseenTotal: 0)
        case .anonymous(_):
            return .init(items: [], unseenTotal: 0)
        }
    }
    public var unwrappedManagerSession: ManagerSession {
        if case .manager(let session) = self.account {
            return session
        }
        fatalError("Could not unwrap manager session")
    }
    
    public var activityBadgeCount: Int {
        if case .manager(let managerSession) = self.account {
            return managerSession.managerData.activity.unseenTotal
        }
        return 0
    }
}

public enum UserType: Equatable, Sendable {
    case manager(managerData: ManagerData, accountInfo: AccountInfo)
    case participant(accountInfo: AccountInfo)
    case anonymoous
    public var role: Role? {
        switch self {
        case .manager:
            return Role.manager
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
    public let segmentationStats: FeedbackSegmentationStats
    public let countStats: FeedbackCountStats
    public var unseenCount: Int
    
    public init(segmentationStats: FeedbackSegmentationStats, countStats: FeedbackCountStats, unseenCount: Int) {
        self.segmentationStats = segmentationStats
        self.countStats = countStats
        self.unseenCount = unseenCount
    }
}

public struct FeedbackSegmentationStats: Equatable, Sendable {
    public let verySadPercentage: Double
    public let sadPercentage: Double
    public let happyPercentage: Double
    public let veryHappyPercentage: Double
    
    public init(
        verySadPercentage: Double,
        sadPercentage: Double,
        happyPercentage: Double,
        veryHappyPercentage: Double
    ) {
        self.verySadPercentage = verySadPercentage
        self.sadPercentage = sadPercentage
        self.happyPercentage = happyPercentage
        self.veryHappyPercentage = veryHappyPercentage
    }
}

public struct FeedbackCountStats: Equatable, Sendable {
    public let verySadCount: Int
    public let sadCount: Int
    public let happyCount: Int
    public let veryHappyCount: Int
    public let commentsCount: Int
    public let uniqueParticipantFeedback: Int
    public init(verySadCount: Int, sadCount: Int, happyCount: Int, veryHappyCount: Int, commentsCount: Int, uniqueParticipantFeedback: Int) {
        self.verySadCount = verySadCount
        self.sadCount = sadCount
        self.happyCount = happyCount
        self.veryHappyCount = veryHappyCount
        self.commentsCount = commentsCount
        self.uniqueParticipantFeedback = uniqueParticipantFeedback
    }
}

public struct ManagerQuestion: Equatable, Hashable, Sendable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public let id: UUID
    public let questionText: String
    public let feedbackType: FeedbackType
    public var feedback: [Feedback]
    public var feedbackSummary: FeedbackSummary?
    
    public init(
        id: UUID,
        questionText: String,
        feedbackType: FeedbackType,
        feedback: [Feedback],
        feedbackSummary: FeedbackSummary?
    ) {
        self.id = id
        self.questionText = questionText
        self.feedbackType = feedbackType
        self.feedback = feedback
        self.feedbackSummary = feedbackSummary
    }
}

public struct EventWrapper: Equatable, Sendable {
    public let event: ManagerEvent
    public let recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    public init(
        event: ManagerEvent,
        recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    ) {
        self.event = event
        self.recentlyUsedQuestions = recentlyUsedQuestions
    }
}

public struct ManagerEvent: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var agenda: String?
    public var date: Date
    public let pinCode: String
    public var durationInMinutes: Int
    public var location : String?
    public let ownerInfo: OwnerInfo
    public var feedbackSummary: FeedbackSummary?
    public var questions: [ManagerQuestion]
    public var end: Date {
        date + TimeInterval(durationInMinutes*60)
    }
    public var formattedDate: String {
        if Calendar.current.dateComponents([.minute], from: date, to: end).minute == 1440 {
            return "\(date.dateAndYear()) - All day"
        } else if Calendar.current.isDate(date, inSameDayAs: end) {
            return "\(date.dateAndYear()) at \(date.timeFormatted())-\(end.timeFormatted())"
        } else {
            return "\(date.dateAndYear()) \(end.timeFormatted()) to \(end.formatted(.dateTime.day())) \(end.formatted(.dateTime.month())) \(end.timeFormatted())"
        }
    }
    
    public init(
        id: UUID,
        title: String,
        agenda: String? = nil,
        date: Date,
        pinCode: String,
        durationInMinutes: Int,
        location: String? = nil,
        ownerInfo: OwnerInfo,
        feedbackSummary: FeedbackSummary?,
        questions: [ManagerQuestion]
    ) {
        self.id = id
        self.title = title
        self.agenda = agenda
        self.date = date
        self.pinCode = pinCode
        self.durationInMinutes = durationInMinutes
        self.location = location
        self.ownerInfo = ownerInfo
        self.feedbackSummary = feedbackSummary
        self.questions = questions
    }
}

public struct ManagerData: Equatable, Sendable {
    public var managerEvents: IdentifiedArrayOf<ManagerEvent>
    public var activity: Activity
    public var recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    public init(
        managerEvents: IdentifiedArrayOf<ManagerEvent>,
        activity: Activity,
        recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    ) {
        self.managerEvents = managerEvents
        self.activity = activity
        self.recentlyUsedQuestions = recentlyUsedQuestions
    }
}

public struct RecentlyUsedQuestions: Equatable, Sendable, Hashable {
    public let questionText: String
    public let feedbackType: FeedbackType
    public let updatedAt: Date
    public init(
        questionText: String,
        feedbackType: FeedbackType,
        updatedAt: Date
    ) {
        self.questionText = questionText
        self.feedbackType = feedbackType
        self.updatedAt = updatedAt
    }
}

public extension NewSession {
    
    mutating func updateOrAppendManagerEvent(_ event: ManagerEvent) {
        self.managerData?.managerEvents.updateOrAppend(event)
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
        self.managerData?.managerEvents.remove(id: id)
    }
    
    func getManagerEventId(_ id: UUID) -> ManagerEvent {
        return self.managerData!.managerEvents[id: id]!
    }
    
    func recentlyUsedQuestions() -> Set<RecentlyUsedQuestions> {
        return self.managerData!.recentlyUsedQuestions
    }
    
    mutating func markEventAsSeen(eventId: UUID) {
        
        guard var event = self.managerData?.managerEvents[id: eventId] else { return }
        
        // Reset event-level feedback
        event.feedbackSummary?.unseenCount = 0
        
        // Reset question-level feedback and feedback properties
        event.questions = event.questions.map { question in
            var updatedQuestion = question
            updatedQuestion.feedbackSummary?.unseenCount = 0
            
            updatedQuestion.feedback = updatedQuestion.feedback.map { feedback in
                var updatedFeedback = feedback
                updatedFeedback.seenByManager = true
                return updatedFeedback
            }
            
            return updatedQuestion
        }
        self.managerData?.managerEvents[id: eventId] = event
        
        var mutableActivity = self.managerData!.activity
        mutableActivity.unseenTotal = mutableActivity.unseenTotal-1
        for index in mutableActivity.items.indices {
            mutableActivity.items[index].seenByManager = true
        }
        self.managerData!.activity = mutableActivity
    }
    
    mutating func updateAccount(name: String?, email: String?, phoneNumber: String?) {
        let updatedAccountInfo: AccountInfo = AccountInfo(
            name: name,
            email: email,
            phoneNumber: phoneNumber
        )
        self.accountInfo = updatedAccountInfo
    }
    
    mutating func updateActivity(_ updatedActivity: Activity) {
        self.managerData?.activity = updatedActivity
    }
    
    mutating func markActivityAsSeen() {
        var mutableActivity = self.managerData!.activity
        mutableActivity.unseenTotal = 0
        for index in mutableActivity.items.indices {
            mutableActivity.items[index].seenByManager = true
        }
        
        self.managerData?.activity = mutableActivity
    }
    
    mutating func updateRecentlyUsedQuestions(_ questions: Set<RecentlyUsedQuestions>) {
        self.managerData?.recentlyUsedQuestions = questions
    }
}
