import Foundation
import OpenAPIURLSession
import OpenAPIRuntime
import FirebaseAuth
import FirebaseMessaging
import Logger
import ComposableArchitecture
import Helpers


public extension APIClient {
    static func live(
        baseUrl: URL,
        deviceId: String
    ) -> APIClient {
        @Dependency(\.logClient) var logger
        let api = Client(
            serverURL: baseUrl,
            configuration: Configuration(),
            transport: URLSessionTransport(),
            middlewares: [
                AuthorisationMiddleware(),
                DelayMiddleware()
            ]
        )
        
        let sessionCache = SessionCache()
        
        return APIClient(
            deleteAccount: {
                try await withAuthorization {
                    let _ = try await api.deleteAccount(.init())
                    return ()
                }
            },
            updateAccount: {
                name,
                email,
                phoneNumber in
                
                try await withAuthorization {
                    _ = try await api.modifyAccount(
                        .init(
                            body: .json(
                                .init(
                                    name: name.nilIfEmpty,
                                    email: email.nilIfEmpty,
                                    phoneNumber: phoneNumber.nilIfEmpty
                                )
                            )
                        )
                    ).ok
                    await sessionCache.updateAccount(
                        name: name.nilIfEmpty,
                        email: email.nilIfEmpty,
                        phoneNumber: phoneNumber.nilIfEmpty
                    )
                    return ()
                }
            },
            updateFcmToken: { fcmToken in
                try await withAuthorization {
                    _ = try await api.updateFcmToken(body: .json(.init(fcmToken: fcmToken)))
                    return ()
                }
            },
            getSession: {
                try await withAuthorization {
                    let sessionDto = try await api.getSession().ok.body.json
                    let newSession = Session(sessionDto)
                    await sessionCache.updateSession(newSession)
                    return newSession
                }
            },
            startFeedbackSession: { pinCode in
                try await withAuthorization {
                    let response = try await api.startFeedbackSession(.init(body: .json(.init(pinCode: pinCode))))
                    switch response {
                    case .ok(let output):
                        return .init(try output.body.json, pinCode: pinCode)
                    case .internalServerError(let internalError):
                        let apiErrorDto = try internalError.body.json
                        throw ApiError(apiErrorDto: apiErrorDto)
                    case .undocumented(statusCode: _, _):
                        throw URLError(.unknown)
                    }
                }
            },
            sendFeedback: { feedback, pinCode in
                try await withAuthorization {
                    let response = try await api.sendFeedback(
                        .init(
                            body: .json(
                                .init(
                                    feedback: feedback.map { .init($0) },
                                    pinCode: pinCode
                                )
                            )
                        )
                    ).ok.body.json
                    await sessionCache.updateOrAppendParticipantEvent(ParticipantEvent(response.event))
                    return response.shouldPresentRatingPrompt
                }
            },
            createEvent: { eventInput in
                try await withAuthorization {
                    let managerEvent = ManagerEvent(try await api.createEvent(body: .json(.init(eventInput))).ok.body.json)
                    await sessionCache.updateOrAppendManagerEvent(managerEvent)
                    return managerEvent
                }
            },
            updateEvent: { eventInput, eventId in
                try await withAuthorization {
                    let managerEvent = ManagerEvent(try await api.updateEvent(path: .init(eventId: eventId.uuidString), body: .json(.init(eventInput))).ok.body.json)
                    await sessionCache.updateOrAppendManagerEvent(managerEvent)
                    return managerEvent
                }
            },
            deleteEvent: { eventId in
                try await withAuthorization {
                    _ = try await api.deleteEvent(path: .init(eventId: eventId.uuidString)).ok
                    await sessionCache.deleteEvent(eventId)
                    return ()
                }
            },
            createAccount: { optionalRole in
                return try await withAuthorization(forceRefreshAfter: true) {
                    let fcmToken = Messaging.messaging().fcmToken
                    let sessionDto = try await api.createAccount(
                        .init(
                            body: .json(
                                .init(
                                    requestedRole: optionalRole?.rawValue.uppercasingFirst(),
                                    fcmToken: fcmToken
                                )
                            )
                        )
                    ).ok.body.json
                    let session = Session(sessionDto)
                    await sessionCache.updateSession(session)
                    return session
                }
            },
            sessionChangedListener: {
                await sessionCache.sessionChangedListener()
                
            },
            joinEvent: { pinCode in
                do {
                    return try await withAuthorization {
                        
                        let response = try await api.joinEvent(.init(path: .init(pinCode: pinCode)))
                        
                        switch response {
                        case .ok(let output):
                            let participantEvent = try output.body.json
                            await sessionCache.updateOrAppendParticipantEvent(ParticipantEvent(participantEvent))
                        case .internalServerError(let internalError):
                            let apiErrorDto = try internalError.body.json
                            throw ApiError(apiErrorDto: apiErrorDto)
                        case .undocumented(statusCode: _, _):
                            throw URLError(.unknown)
                        }
                    }
                }
            },
            markEventAsSeen: { eventId in
                try await withAuthorization {
                    _ = try await api.markEventAsSeen(.init(path: .init(eventId: eventId.uuidString)))
                    await sessionCache.markEventAsSeen(eventId: eventId)
                    return ()
                }
                return ()
            },
            updateAccountRole: { role in
                try await withAuthorization(forceRefreshAfter: true) {
                    _ = try await api.updateRole(.init(body: .json(.init(role: role.rawValue.uppercasingFirst()))))
                    return ()
                }
            },
            getMockToken: {
                return try await api.mockIdToken(body: .json(.init(role: "Manager", id: "mock_id"))).ok.body.json.token
            },
            getUpdatedSession: {
                try await withAuthorization {
                    let updatedSessionDto = try await api.getUpdatedSession().ok.body.json
                    let updatedSession: UpdatedSession = .init(updatedSessionDto)
                    await sessionCache.updateActivity(updatedSession.activity)
                    for updatedEvent in updatedSession.events {
                        await sessionCache.updateOrAppendManagerEvent(updatedEvent)
                    }
                    return updatedSession
                }
            },
            markActivityAsSeen: {
                try await withAuthorization {
                    let _ = try await api.markActivityAsSeen().ok
                    await sessionCache.markActivityAsSeen()
                    return ()
                }
            }
        )
    }
}


