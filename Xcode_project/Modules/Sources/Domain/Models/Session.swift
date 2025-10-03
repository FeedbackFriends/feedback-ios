import Foundation
import ComposableArchitecture

public struct ManagerSession: Equatable, Sendable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var managerData: ManagerData
    public var accountInfo: AccountInfo
    public init(
        participantEvents: IdentifiedArrayOf<ParticipantEvent>,
        managerData: ManagerData,
        accountInfo: AccountInfo
    ) {
        self.participantEvents = participantEvents
        self.managerData = managerData
        self.accountInfo = accountInfo
    }
}

public struct ParticipantSession: Equatable, Sendable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var accountInfo: AccountInfo
    public init(
        participantEvents: IdentifiedArrayOf<ParticipantEvent>,
        accountInfo: AccountInfo
    ) {
        self.participantEvents = participantEvents
        self.accountInfo = accountInfo
    }
}

public struct AnonymousSession: Equatable, Sendable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public init(
        participantEvents: IdentifiedArrayOf<ParticipantEvent>
    ) {
        self.participantEvents = participantEvents
    }
}

public struct Session: Equatable, Sendable {
    
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
        case .participant:
            return .init(items: [], unseenTotal: 0)
        case .anonymous:
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
    public let pinCode: PinCode?
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
        pinCode: PinCode?,
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

public struct ParticipantQuestion: Equatable, Sendable, Identifiable {
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
    public var feedbackSummary: QuestionFeedbackSummary?
    
    public init(
        id: UUID,
        questionText: String,
        feedbackType: FeedbackType,
        feedback: [Feedback],
        feedbackSummary: QuestionFeedbackSummary?
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
    public let pinCode: PinCode?
    public var durationInMinutes: Int
    public var location: String?
    public let ownerInfo: OwnerInfo
    public var feedbackSummary: FeedbackSummary?
    public var questions: [ManagerQuestion]
    public var end: Date {
        date + TimeInterval(durationInMinutes * 60)
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
        pinCode: PinCode?,
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
    public var feedbackSessionHash: UUID
    public init(
        managerEvents: IdentifiedArrayOf<ManagerEvent>,
        activity: Activity,
        recentlyUsedQuestions: Set<RecentlyUsedQuestions>,
        feedbackSessionHash: UUID
    ) {
        self.managerEvents = managerEvents
        self.activity = activity
        self.recentlyUsedQuestions = recentlyUsedQuestions
        self.feedbackSessionHash = feedbackSessionHash
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

public enum QuestionFeedbackSummary: Equatable, Sendable {
    case emojiQuestionFeedbackSummary(unseenCount: Int, emojiQuestionFeedbackSummary: EmojiQuestionFeedbackSummary)
    case thumpsQuestionFeedbackSummary(unseenCount: Int, thumpsQuestionFeedbackSummary: ThumpsQuestionFeedbackSummary)
    case opinionQuestionFeedbackSummary(unseenCount: Int, opinionQuestionFeedbackSummary: OpinionQuestionFeedbackSummary)
    case zeroToTenQuestionFeedbackSummary(unseenCount: Int, zeroToTenQuestionFeedbackSummary: ZeroToTenQuestionFeedbackSummary)
    case commentQuestionFeedbackSummary(unseenCount: Int)
    
    public var commentCount: Int {
        switch self {
            
        case .emojiQuestionFeedbackSummary(unseenCount: _, emojiQuestionFeedbackSummary: let emojiQuestionFeedbackSummary):
            emojiQuestionFeedbackSummary.emojiFeedbackCountStats.commentsCount
        case .thumpsQuestionFeedbackSummary(unseenCount: _, thumpsQuestionFeedbackSummary: let thumpsQuestionFeedbackSummary):
            thumpsQuestionFeedbackSummary.thumpsFeedbackCountStats.commentsCount
        case .opinionQuestionFeedbackSummary(unseenCount: _, opinionQuestionFeedbackSummary: let opinionQuestionFeedbackSummary):
            opinionQuestionFeedbackSummary.opinionFeedbackCountStats.commentsCount
        case .zeroToTenQuestionFeedbackSummary(unseenCount: _, zeroToTenQuestionFeedbackSummary: let zeroToTenQuestionFeedbackSummary):
            zeroToTenQuestionFeedbackSummary.zeroToTenFeedbackCountStats.commentsCount
        case .commentQuestionFeedbackSummary(unseenCount: _):
            #warning("Fix me")
            999999999
        }
    }

    public var unseenCount: Int {
        get {
            switch self {
            case let .emojiQuestionFeedbackSummary(unseenCount, _):
                return unseenCount
            case let .thumpsQuestionFeedbackSummary(unseenCount, _):
                return unseenCount
            case let .opinionQuestionFeedbackSummary(unseenCount, _):
                return unseenCount
            case let .zeroToTenQuestionFeedbackSummary(unseenCount, _):
                return unseenCount
            case .commentQuestionFeedbackSummary(unseenCount: let unseenCount):
                return unseenCount
            }
        }
        set {
            switch self {
            case let .emojiQuestionFeedbackSummary(_, emoji):
                self = .emojiQuestionFeedbackSummary(unseenCount: newValue, emojiQuestionFeedbackSummary: emoji)
            case let .thumpsQuestionFeedbackSummary(_, thumps):
                self = .thumpsQuestionFeedbackSummary(unseenCount: newValue, thumpsQuestionFeedbackSummary: thumps)
            case let .opinionQuestionFeedbackSummary(_, opinion):
                self = .opinionQuestionFeedbackSummary(unseenCount: newValue, opinionQuestionFeedbackSummary: opinion)
            case let .zeroToTenQuestionFeedbackSummary(_, zeroToTen):
                self = .zeroToTenQuestionFeedbackSummary(unseenCount: newValue, zeroToTenQuestionFeedbackSummary: zeroToTen)
            case .commentQuestionFeedbackSummary:
                self = .commentQuestionFeedbackSummary(unseenCount: newValue)
            }
        }
    }
}
   
public struct ZeroToTenQuestionFeedbackSummary: Equatable, Sendable {
    let zeroToTenFeedbackCountStats: ZeroToTenFeedbackCountStats
    let zeroToTenFeedbackSegmentationStats: ZeroToTenFeedbackCountSegmentationStats
}

public struct ZeroToTenFeedbackCountStats: Equatable, Sendable {
    let value0: Int
    let value1: Int
    let value2: Int
    let value3: Int
    let value4: Int
    let value5: Int
    let value6: Int
    let value7: Int
    let value8: Int
    let value9: Int
    let value10: Int
    let commentsCount: Int
}

public struct ZeroToTenFeedbackCountSegmentationStats: Equatable, Sendable {
    let value0Percentage: Double
    let value1Percentage: Double
    let value2Percentage: Double
    let value3Percentage: Double
    let value4Percentage: Double
    let value5Percentage: Double
    let value6Percentage: Double
    let value7Percentage: Double
    let value8Percentage: Double
    let value9Percentage: Double
    let value10Percentage: Double
}

public struct OpinionQuestionFeedbackSummary: Equatable, Sendable {
    let opinionFeedbackCountStats: OpinionFeedbackCountStats
    let opinionFeedbackSegmentationStats: OpinionFeedbackCountSegmentationStats
}

public struct OpinionFeedbackCountStats: Equatable, Sendable {
    let stronglyAgree: Int
    let agree: Int
    let stronglyDisagree: Int
    let disagree: Int
    let commentsCount: Int
}

public struct OpinionFeedbackCountSegmentationStats: Equatable, Sendable {
    let stronglyAgreePercentage: Double
    let agreePercentage: Double
    let stronglyDisagreePercentage: Double
    let disagreePercentage: Double
}

public struct ThumpsQuestionFeedbackSummary: Equatable, Sendable {
    let thumpsFeedbackCountStats: ThumpsFeedbackCountStats
    let thumpsFeedbackSegmentationStats: ThumpsFeedbackCountSegmentationStats
}

public struct ThumpsFeedbackCountStats: Equatable, Sendable {
    let upCount: Int
    let downCount: Int
    let commentsCount: Int
}

public struct ThumpsFeedbackCountSegmentationStats: Equatable, Sendable {
    let upPercentage: Double
    let downPercentage: Double
}

public struct EmojiQuestionFeedbackSummary: Equatable, Sendable {
    let emojiFeedbackCountStats: EmojiFeedbackCountStats
    let emojiFeedbackSegmentationStats: EmojiFeedbackSegmentationStats
}

public struct EmojiFeedbackCountStats: Equatable, Sendable {
    let verySadCount: Int
    let sadCount: Int
    let happyCount: Int
    let veryHappyCount: Int
    let commentsCount: Int
}

public struct EmojiFeedbackSegmentationStats: Equatable, Sendable {
    let verySadPercentage: Double
    let sadPercentage: Double
    let happyPercentage: Double
    let veryHappyPercentage: Double
}
