import Foundation
import OpenAPIURLSession
import OpenAPIRuntime
import FirebaseAuth
import Logger
import ComposableArchitecture
import Helpers

public extension APIClient {
    static func live(
        baseUrl: URL,
        deviceId: UUID
    ) -> APIClient {
        @Dependency(\.logClient) var logger
        let api = Client(
            serverURL: baseUrl,
            configuration: Configuration(),
            transport: URLSessionTransport(),
            middlewares: [
                AuthorisationMiddleware()
//                LoggingMiddleware()
            ]
        )
        
        let sessionCache = SessionCache()
        
        return APIClient(
            deleteAccount: {
                try await withAuthorization {
                    _ = try await api.deleteAccount(.init()).ok
                    return ()
                }
            },
            _updateAccount: {
                name,
                email,
                phoneNumber in
                
                try await withAuthorization(forceRefreshAfter: true) {
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
                    sessionCache.updateAccount(
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
                try await withAuthorization(forceRefreshAfter: true) {
                    let sessionDto = try await api.getSession().ok.body.json
                    let newSession = Session(sessionDto)
                    sessionCache.updateSession(newSession)
                    return newSession
                }
            },
            startFeedbackSession: { pinCode in
                try await withAuthorization {
                    let feedbackSessionDto = try await api.startFeedbackSession(.init(body: .json(.init(pinCode: pinCode)))).ok.body.json
                    return .init(feedbackSessionDto, pinCode: pinCode)
                }
            },
            _sendFeedback: { feedback, pinCode in
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
                    sessionCache.updateOrAppendAttendingEvent(ParticipantEvent(response.event))
                    return response.shouldPresentRatingPrompt
                }
            },
            createEvent: { eventInput in
                try await withAuthorization {
                    let managerEvent = ManagerEvent(try await api.createEvent(body: .json(.init(eventInput))).ok.body.json)
                    sessionCache.updateOrAppendManagerEvent(managerEvent)
                    return managerEvent
                }
            },
            updateEvent: { eventInput, eventId in
                try await withAuthorization {
                    let managerEvent = ManagerEvent(try await api.updateEvent(path: .init(eventId: eventId.uuidString), body: .json(.init(eventInput))).ok.body.json)
                    sessionCache.updateOrAppendManagerEvent(managerEvent)
                    return managerEvent
                }
            },
            deleteEvent: { eventId in
                try await withAuthorization {
                    _ = try await api.deleteEvent(path: .init(eventId: eventId.uuidString)).ok
                    sessionCache.deleteEvent(eventId)
                    return ()
                }
            },
            createAccount: { optionalClaim in
                try await withAuthorization(forceRefreshAfter: true) {
                    let claim: Components.Schemas.CreateAccountInput.requestedClaimPayload? =
                    optionalClaim.flatMap { .init(rawValue: $0.rawValue.capitalized) }
                    
                    let sessionDto = try await api.createAccount(.init(body: .json(.init(requestedClaim: claim)))).ok.body.json
                    let session = Session(sessionDto)
                    sessionCache.updateSession(session)
                    return session
                }
            },
            sessionChangedListener: {
                sessionCache.sessionChangedListener()
                
            },
            joinEvent: { eventPin in
                try await withAuthorization {
                    let participantEvent = try await api.acceptEvent(.init(path: .init(eventCode: eventPin))).ok.body.json
                    sessionCache.updateOrAppendAttendingEvent(ParticipantEvent(participantEvent))
                }
            },
            resetNewFeedbackForEvent: { eventId in
                try await withAuthorization {
                    _ = try await api.resetNewFeedback(.init(path: .init(eventId: eventId.uuidString)))
                    sessionCache.resetNewFeedbackForEvent(eventId: eventId)
                    return ()
                }
                return ()
            },
            updateAccountClaim: { claim in
                try await withAuthorization(forceRefreshAfter: true) {
                    _ = try await api.updateClaim(.init(body: .json(.init(claim: .init(rawValue: claim.rawValue.capitalized)!))))
                    return ()
                }
            }
        )
    }
}
