import Foundation
import OpenAPIRuntime
import Model
import OpenAPIURLSession
import ComposableArchitecture

public extension Feedback {
    init(_ feedback: Components.Schemas.FeedbackEntity) {
        switch feedback.feedbackType {
        case .emoji:
            self = .init(
                type: .emoji(
                    emoji: .init(rawValue: feedback.emoji!.rawValue.lowercasingFirst())!,
                    comment: feedback.comment
                ),
                questionId: UUID(uuidString: feedback.questionId)!,
                seenByManager: feedback.seenByManager,
                createdAt: feedback.createdAt
            )
        case .comment:
            self = .init(
                type: .comment(comment: feedback.comment!),
                questionId: UUID(uuidString: feedback.questionId)!,
                seenByManager: feedback.seenByManager,
                createdAt: feedback.createdAt
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

public extension Components.Schemas.FeedbackInput {
    init(_ feedback: FeedbackInput) {
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

public extension Components.Schemas.FeedbackInput.ThumbsUpThumpsDownPayload {
    init(input: ThumbsUpThumpsDown) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

public extension Components.Schemas.FeedbackInput.EmojiPayload {
    init(input: Emoji) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

public extension Components.Schemas.FeedbackInput.OpinionPayload {
    init(input: Opinion) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

public extension ManagerEvent {
    init(_ event: Components.Schemas.ManagerEventDto) {
        let feedbackSummary: FeedbackSummary? = if let eventSummary = event.feedbackSummary {
            FeedbackSummary(
                segmentationStats: .init(
                    verySadPercentage: eventSummary.segmentationStats.verySadPercentage,
                    sadPercentage: eventSummary.segmentationStats.sadPercentage,
                    happyPercentage: eventSummary.segmentationStats.happyPercentage,
                    veryHappyPercentage: eventSummary.segmentationStats.veryHappyPercentage
                ),
                countStats: .init(
                    verySadCount: Int(eventSummary.countStats.verySadCount),
                    sadCount: Int(eventSummary.countStats.sadCount),
                    happyCount: Int(eventSummary.countStats.happyCount),
                    veryHappyCount: Int(eventSummary.countStats.veryHappyCount),
                    commentsCount: Int(eventSummary.countStats.commentsCount),
                    uniqueParticipantFeedback: Int(eventSummary.countStats.uniqueParticipantFeedback)
                ),
                unseenCount: Int(eventSummary.unseenCount)
            )
        } else {
            nil
        }
        self.init(
            id: UUID(uuidString: event.id)!,
            title: event.title,
            agenda: event.agenda,
            date: event.date,
            pinCode: PinCode(value: event.pinCode ?? "Expired"),
            durationInMinutes: Int(event.durationInMinutes),
            location: event.location,
            ownerInfo: .init(
                name: event.ownerInfo.name,
                email: event.ownerInfo.email,
                phoneNumber: event.ownerInfo.phoneNumber
            ),
            feedbackSummary: feedbackSummary,
            questions: event.questions.map {
                let feedbackSummary: FeedbackSummary? = if let questionSummary = $0.feedbackSummary {
                    FeedbackSummary(
                        segmentationStats: .init(
                            verySadPercentage: questionSummary.segmentationStats.verySadPercentage,
                            sadPercentage: questionSummary.segmentationStats.sadPercentage,
                            happyPercentage: questionSummary.segmentationStats.happyPercentage,
                            veryHappyPercentage: questionSummary.segmentationStats.veryHappyPercentage
                        ),
                        countStats: .init(
                            verySadCount: Int(questionSummary.countStats.verySadCount),
                            sadCount: Int(questionSummary.countStats.sadCount),
                            happyCount: Int(questionSummary.countStats.happyCount),
                            veryHappyCount: Int(questionSummary.countStats.veryHappyCount),
                            commentsCount: Int(questionSummary.countStats.commentsCount),
                            uniqueParticipantFeedback: Int(questionSummary.countStats.uniqueParticipantFeedback)
                        ),
                        unseenCount: Int(questionSummary.unseenCount)
                    )
                } else {
                    nil
                }
                return ManagerQuestion(
                    id: UUID(uuidString: $0.id)!,
                    questionText: $0.questionText,
                    feedbackType: .init($0.feedbackType.rawValue),
                    feedback: $0.feedback.map { Feedback($0) },
                    feedbackSummary: feedbackSummary
                )
            }
        )
    }
}

public extension EventWrapper {
    init(_ event: Components.Schemas.EventWrapperDto) {
        self.init(
            event: .init(event.event),
            recentlyUsedQuestions:
                Set(
                    event.recentlyUsedQuestions.map {
                        .init(
                            questionText: $0.questionText,
                            feedbackType: .init($0.feedbackType.rawValue),
                            updatedAt: $0.updatedAt
                        )
                    }
                )
        )
    }
}

public extension ParticipantEvent {
    init(_ event: Components.Schemas.ParticipantEventDto) {
        self.init(
            id: UUID(uuidString: event.id)!,
            title: event.title,
            agenda: event.agenda,
            date: event.date,
            pinCode: event.pinCode.map { PinCode(value: $0) },
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

public extension Components.Schemas.EventInput {
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

public extension FeedbackSession {
    init(_ feedbackSession: Components.Schemas.FeedbackSessionDto, pinCode: PinCode) {
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

public extension ApiError {
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

public extension DomainCode {
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

public extension Session {
    init(_ session: Components.Schemas.SessionDto) {
        let accountInfo: AccountInfo = AccountInfo(
            name: session.accountInfo.name,
            email: session.accountInfo.email,
            phoneNumber: session.accountInfo.phoneNumber
        )
        let role: Role? = switch session.role {
        case .some("Participant"):
                .participant
        case .some("Manager"):
                .manager
        default:
            nil
        }
        
        let managerData: ManagerData? = session.managerData.flatMap {
            ManagerData(
                managerEvents: .init(uniqueElements: $0.managerEvents.map { .init($0) }),
                activity: .init($0.activity),
                recentlyUsedQuestions: .init($0.recentlyUsedQuestions.map {
                    .init(
                        questionText: $0.questionText,
                        feedbackType: .init($0.feedbackType.rawValue),
                        updatedAt: $0.updatedAt
                    )
                }),
                feedbackSessionHash: .init(uuidString: $0.feedbackSessionHash)!
            )
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
                        pinCode: $0.pinCode.map { PinCode(value: $0) },
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
            managerData: managerData,
            accountInfo: accountInfo,
            role: role
        )
    }
}

public extension Activity {
    init(_ activity: Components.Schemas.ActivityDto) {
        self.init(
            items: activity.items.map {
                .init(
                    id: UUID(uuidString: $0.id)!,
                    date: $0.date,
                    eventTitle: $0.eventTitle,
                    eventId: UUID(uuidString: $0.eventId)!,
                    newFeedbackCount: Int($0.newFeedbackCount),
                    seenByManager: $0.seenByManager
                )
            },
            unseenTotal: Int(activity.unseenTotal)
        )
    }
}
