import Foundation
import OpenAPIRuntime
import Helpers
import OpenAPIURLSession
import ComposableArchitecture

extension Feedback {
    init(_ feedback: Components.Schemas.FeedbackEntity) {
        switch feedback.feedbackType {
        case .emoji:
            
            self = .init(
                type: .emoji(
                    emoji: .init(rawValue: feedback.emoji!.rawValue.lowercasingFirst())!,
                    comment: feedback.comment
                ),
                questionId: UUID(uuidString: feedback.questionId)!,
                isNew: feedback.isNew
            )
        case .comment:
            self = .init(
                type: .comment(comment: feedback.comment!),
                questionId: UUID(uuidString: feedback.questionId)!,
                isNew: feedback.isNew
            )
        case .thumpsUpThumpsDown:
            fatalError()
        case .oneToTen:
            fatalError()
        case .opinion:
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
                feedbackType: .emoji
            )
        case .comment(comment: let comment):
            self.init(
                comment: comment,
                questionId: feedback.questionId.uuidString,
                feedbackType: .comment
            )
        case .thumpsUpThumpsDown(thumbsUpThumpsDown: let thumbsUpThumpsDown, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                thumbsUpThumpsDown: .init(input: thumbsUpThumpsDown),
                questionId: feedback.questionId.uuidString,
                feedbackType: .thumpsUpThumpsDown
            )
        case .opinion(opinion: let opinion, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                opinion: .init(input: opinion),
                questionId: feedback.questionId.uuidString,
                feedbackType: .opinion
            )
        case .oneToTen(oneToTen: let oneToTen, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                oneToTen: Int32(oneToTen),
                questionId: feedback.questionId.uuidString,
                feedbackType: .oneToTen
            )
        }
    }
}

extension Components.Schemas.FeedbackInput.ThumbsUpThumpsDownPayload {
    init(input: ThumbsUpThumpsDown) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

extension Components.Schemas.FeedbackInput.EmojiPayload {
    init(input: Emoji) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

extension Components.Schemas.FeedbackInput.OpinionPayload {
    init(input: Opinion) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
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
            ),
            recentlyJoined: event.recentlyJoined
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

extension ApiError {
    init(apiErrorDto: Components.Schemas.ApiError) {
        self.init(
            timestamp: apiErrorDto.timestamp,
            message: apiErrorDto.message,
            domainCode: apiErrorDto.domainCode.flatMap { .init(domainCodeDto: $0) },
            exceptionType: apiErrorDto.exceptionType,
            path: apiErrorDto.path
        )
    }
}

extension DomainCode {
    init(domainCodeDto: Components.Schemas.ApiError.DomainCodePayload) {
        switch domainCodeDto {
            
        case .feedbackAlreadySubmitted:
            self = .feedbackAlreadySubmitted
            
        case .eventAlreadyJoined:
            self = .eventAlreadyJoined
        case .cannotJoinOwnEvent:
            fatalError()
        case .cannotGiveFeedbackToSelf:
            fatalError()
        }
    }
}

extension Session {
    init(_ session: Components.Schemas.SessionDto) {
        let accountInfo: AccountInfo = AccountInfo(
            name: session.accountInfo.name,
            email: session.accountInfo.email,
            phoneNumber: session.accountInfo.phoneNumber
        )
        print("*********** role \(session.role ?? "")")
        let role: Role? = switch session.role {
        case .some("Participant"):
                .participant
        case .some("Organizer"):
                .organizer
        default:
            nil
        }
        let userType: UserType =
        switch session.role {
        case .some("Organizer"):
                .manager(
                    managerData: .init(
                        managerEvents: IdentifiedArray(uniqueElements: session.managerData?.managerEvents.map { .init($0) } ?? [])
                    ),
                    accountInfo: accountInfo
                )
        case .some("Participant"):
                .participant(accountInfo: accountInfo)
        default:
                .anonymoous
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
                        ),
                        recentlyJoined: $0.recentlyJoined
                    )
                }
            ),
            userType: userType,
            role: role
        )
    }
}
