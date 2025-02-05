import Foundation
import ComposableArchitecture
import Helpers

public struct Session: Equatable {
    public var participantEvents: IdentifiedArrayOf<ParticipantEvent>
    public var userType: UserType
    public var claim: Claim?
}

public enum UserType: Equatable {
    case manager(managerData: ManagerData, accountInfo: AccountInfo)
    case participant(accountInfo: AccountInfo)
    case anonymoous
}

public struct AccountInfo: Equatable {
    public let name: String?
    public let email: String?
    public let phoneNumber: String?
}

public struct ParticipantEvent: Equatable, Identifiable {
    public let id: UUID
    public let title: String
    public let agenda: String?
    public let date: Date
    // durationInMinutes: Int
    public let pinCode: String
    public let location: String?
    public let durationInMinutes: Int
    public let questions: [ParticipantQuestion]
    public let feedbackSubmitted: Bool
    public let ownerInfo: OwnerInfo
}

public struct OwnerInfo: Equatable {
    public let name: String?
    public let email: String?
    public let phoneNumber: String?
}
public struct ParticipantQuestion: Equatable {
    public let id: UUID
    public let questionText: String
    public let feedbackType: FeedbackType
}

public struct FeedbackSummary: Equatable {
    public let totalFeedback: Int
    public let verySadPercentage: Double
    public let sadPercentage: Double
    public let happyPercentage: Double
    public let veryHappyPercentage: Double
}

public struct QuestionFeedbackSummary: Equatable {
    public let totalFeedback: Int
    public let verySadCount: Int
    public let sadCount: Int
    public let happyCount: Int
    public let veryHappyCount: Int
}

public struct ManagerQuestion: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public let id: UUID
    public let questionText: String
    public let feedbackType: FeedbackType
    public var feedback: [Feedback]?
    public let feedbackSummary: QuestionFeedbackSummary?
    public var newFeedbackForQuestion: Int
}

public struct ManagerEvent: Equatable, Identifiable {
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
}

public struct ManagerData: Equatable {
    public var managerEvents: IdentifiedArrayOf<ManagerEvent>
}


extension Session {
    init(_ session: Components.Schemas.SessionDto) {

        let accountInfo: AccountInfo = AccountInfo(
            name: session.accountInfo.name,
            email: session.accountInfo.email,
            phoneNumber: session.accountInfo.phoneNumber
        )
        let claim: Claim? = switch session.claim {
        case .Participant:
                .participant
        case .Manager:
                .manager
        case nil:
                nil
        }
        let userType: UserType =
        switch session.claim {
        case .none:
                .anonymoous
        case .Manager:
                .manager(
                    managerData: .init(
                        managerEvents: IdentifiedArray(uniqueElements: session.managerData?.managerEvents.map { .init($0) } ?? [])
                    ),
                    accountInfo: accountInfo
                )
        case .Participant:
                .participant(accountInfo: accountInfo)
        }
        self.init(
            participantEvents: .init(
                uniqueElements: session.participantEvents.map {
                    guard let id = UUID(uuidString: $0.id) else {
                        fatalError("Could not parse UUID for participant event: \($0.id)")
                    }
                    return ParticipantEvent(
                        id: id,
                        title: $0.title,
                        agenda: $0.agenda,
                        date: $0.date,
                        pinCode: $0.pinCode,
                        location: $0.location,
                        durationInMinutes: Int($0.durationInMinutes),
                        questions: $0.questions.map {
                            guard let id = UUID(uuidString: $0.id) else {
                                fatalError("Could not parse UUID for participant question: \($0.id)")
                            }
                            return ParticipantQuestion(
                                id: id,
                                questionText: $0.questionText,
                                feedbackType: FeedbackType($0.feedbackType.rawValue)
                            )
                        },
                        feedbackSubmitted: $0.feedbackSubmited,
                        ownerInfo: OwnerInfo(
                            name: $0.ownerInfo.name,
                            email: $0.ownerInfo.email,
                            phoneNumber: $0.ownerInfo.phoneNumber
                        )
                    )
                }
            ),
            userType: userType,
            claim: claim
        )
    }
}

public extension Session {
    
    mutating func updateOrAppendManagerEvent(_ event: ManagerEvent) {
        guard case let .manager(managerData: managerData, accountInfo: accountInfo) = self.userType else { return }
        var mutableManagerData = managerData
        mutableManagerData.managerEvents.updateOrAppend(event)
        self.userType = .manager(managerData: mutableManagerData, accountInfo: accountInfo)
    }
    
    mutating func updateOrAppendAttendingEvent(_ event: ParticipantEvent) {
        participantEvents.updateOrAppend(event)
    }
    
    mutating func updateAttendingEvent(_ event: ParticipantEvent) {
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
