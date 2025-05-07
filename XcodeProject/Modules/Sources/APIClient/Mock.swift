import Foundation
import OpenAPIURLSession
import OpenAPIRuntime
import Logger
import ComposableArchitecture
import Model
import OpenAPI

struct Mock: APIProtocol {
    let session = Components.Schemas.SessionDto.init(
        role: "Manager",
        accountInfo: .init(
            name: "Nicolai",
            email: "nicolai@nicolai.com",
            phoneNumber: "45 00 00 00 00"
        ),
        participantEvents: .init(
            [
                .init(
                    id: UUID().uuidString,
                    title: "",
                    date: Date(),
                    pinCode: "0001",
                    durationInMinutes: 30,
                    ownerInfo: .init(
                        name: "Nicolai",
                        email: "nicolai@nicolai.com",
                        phoneNumber: "45 00 00 00 00"
                    ),
                    questions: [
                        .init(
                            id: UUID().uuidString,
                            questionText: "",
                            feedbackType: .emoji
                        )
                    ],
                    feedbackSubmited: false,
                    recentlyJoined: true
                )
            ]
        ),
        managerData: .init(
            managerEvents: [
                .init(
                    id: UUID().uuidString,
                    title: "",
                    date: Date(),
                    durationInMinutes: 30,
                    ownerInfo: .init(name: "Henrik", email: "Henriksen", phoneNumber: "00 00 00 00"),
                    questions: [
                        .init(
                            id: UUID().uuidString,
                            questionText: "",
                            feedbackType: .emoji,
                            feedback: [
                                .init(
                                    id: UUID().uuidString,
                                    feedbackType: .emoji,
                                    emoji: .happy,
                                    questionId: "",
                                    seenByManager: true,
                                    createdAt: Date()
                                )
                            ],
                            feedbackSummary: nil
                        )
                    ]
                )
            ],
            activity: .init(
                items: [],
                unseenTotal: 32
            ),
            recentlyUsedQuestions: [
                .init(
                    questionText: "How was the estimated time?",
                    feedbackType: .emoji,
                    updatedAt: Date()
                )
            ]
        )
    )
    func markActivityAsSeen(_ input: Operations.MarkActivityAsSeen.Input) async throws -> Operations.MarkActivityAsSeen.Output {
        .ok(.init())
    }
    
    func getUpdatedSession(_ input: Operations.GetUpdatedSession.Input) async throws -> Operations.GetUpdatedSession.Output {
        .ok(
            .init(
                body: .json(
                    .init(
                        updatedManagerEvents: [],
                        activity: .init(
                            items: [],
                            unseenTotal: 3
                        )
                    )
                )
            )
        )
    }
    
    func getSession(_ input: Operations.GetSession.Input) async throws -> Operations.GetSession.Output {
        .ok(.init(body: .json(session)))
    }
    
    func mockIdToken(_ input: Operations.MockIdToken.Input) async throws -> Operations.MockIdToken.Output {
        .internalServerError(.init(body: .json(.init())))
    }
    
    func joinEvent(_ input: Operations.JoinEvent.Input) async throws -> Operations.JoinEvent.Output {
        .ok(
            .init(
                body: .json(
                    .init(
                        id: UUID().uuidString,
                        title: "",
                        date: Date(),
                        pinCode: input.path.pinCode,
                        durationInMinutes: 30,
                        ownerInfo: .init(),
                        questions: [
                            .init(
                                id: UUID().uuidString,
                                questionText: "",
                                feedbackType: .emoji
                            )
                        ],
                        feedbackSubmited: false,
                        recentlyJoined: true
                    )
                )
            )
        )
    }
    
    func createEvent(_ input: Operations.CreateEvent.Input) async throws -> Operations.CreateEvent.Output {
        switch input.body {
        case .json(let body):
                .ok(
                    .init(
                        body: .json(
                            .init(
                                event: .init(
                                    id: UUID().uuidString,
                                    title: body.title,
                                    agenda: body.agenda,
                                    date: body.date,
                                    pinCode: "1234",
                                    durationInMinutes: 30,
                                    location: body.location,
                                    ownerInfo: .init(),
                                    feedbackSummary: nil,
                                    questions: [
                                        .init(
                                            id: UUID().uuidString,
                                            questionText: "",
                                            feedbackType: .emoji,
                                            feedback: []
                                        )
                                    ]
                                ),
                                recentlyUsedQuestions: []
                            )
                        )
                    )
                )
        }
    }
    
    func startFeedbackSession(_ input: Operations.StartFeedbackSession.Input) async throws -> Operations.StartFeedbackSession.Output {
        .ok(
            .init(
                body: .json(
                    .init(
                        title: "",
                        agenda: "",
                        questions: [
                            
                        ],
                        ownerInfo: .init(
                            name: "dshj",
                            email: "jdhs@jdhs.com",
                            phoneNumber: "jsdkd"
                        ),
                        date: Date()
                    )
                )
            )
        )
    }
    
    func sendFeedback(_ input: Operations.SendFeedback.Input) async throws -> Operations.SendFeedback.Output {
        .ok(
            .init(
                body: .json(
                    .init(
                        shouldPresentRatingPrompt: Bool.random(),
                        event: .init(
                            id: UUID().uuidString,
                            title: "",
                            agenda: "",
                            date: Date(),
                            pinCode: "1234",
                            durationInMinutes: 30,
                            location: nil,
                            ownerInfo: .init(),
                            questions: [
                                .init(
                                    id: UUID().uuidString,
                                    questionText: "",
                                    feedbackType: .emoji
                                )
                            ],
                            feedbackSubmited: true,
                            recentlyJoined: false
                        )
                    )
                )
            )
        )
    }
    
    func updateFcmToken(_ input: Operations.UpdateFcmToken.Input) async throws -> Operations.UpdateFcmToken.Output {
        .ok(.init())
    }
    
    func updateRole(_ input: Operations.UpdateRole.Input) async throws -> Operations.UpdateRole.Output {
        .ok(.init())
    }
    
    func deleteAccount(_ input: Operations.DeleteAccount.Input) async throws -> Operations.DeleteAccount.Output {
        .ok(.init())
    }
    
    func modifyAccount(_ input: Operations.ModifyAccount.Input) async throws -> Operations.ModifyAccount.Output {
        .ok(.init())
    }
    
    func createAccount(_ input: Operations.CreateAccount.Input) async throws -> Operations.CreateAccount.Output {
        .ok(.init(body: .json(session)))
    }
    
    func sendNotification(_ input: Operations.SendNotification.Input) async throws -> Operations.SendNotification.Output {
        .ok(.init())
    }
    
    func markEventAsSeen(_ input: Operations.MarkEventAsSeen.Input) async throws -> Operations.MarkEventAsSeen.Output {
        .ok(.init())
    }
    
    func deleteEvent(_ input: Operations.DeleteEvent.Input) async throws -> Operations.DeleteEvent.Output {
        .ok(.init())
    }
    
    func updateEvent(_ input: Operations.UpdateEvent.Input) async throws -> Operations.UpdateEvent.Output {
        switch input.body {
        case .json(let body):
                .ok(
                    .init(
                        body: .json(
                            .init(
                                event: .init(
                                    id: input.path.eventId,
                                    title: body.title,
                                    agenda: body.agenda,
                                    date: body.date,
                                    pinCode: "1234",
                                    durationInMinutes: body.durationInMinutes,
                                    location: body.location,
                                    ownerInfo: .init(),
                                    feedbackSummary: nil,
                                    questions: body.questions.map {
                                        .init(
                                            id: UUID().uuidString,
                                            questionText: $0.questionText,
                                            feedbackType: .init(rawValue: $0.feedbackType.rawValue)!,
                                            feedback: []
                                        )
                                    }
                                ),
                                recentlyUsedQuestions: []
                            )
                        )
                    )
                )
        }
    }
}
