import Foundation
import OpenAPIURLSession
import OpenAPIRuntime
import FirebaseAuth
import Logger
import ComposableArchitecture


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
                AuthorisationMiddleware()
//                LoggingMiddleware()
            ]
        )
        
        let sessionCache = SessionCache()
        
        return APIClient(
            deleteAccount: {
                try await withAuthorization {
                    let _ = try await api.deleteAccount(.init())
                    #warning("Delete account from session cache")
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
                    sessionCache.updateOrAppendParticipantEvent(ParticipantEvent(response.event))
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
            createAccount: { optionalRole in
                try await withAuthorization(forceRefreshAfter: true) {
                    let role: Components.Schemas.CreateAccountInput.RequestedRolePayload? =
                    switch optionalRole {
                    case .organizer:
                        Components.Schemas.CreateAccountInput.RequestedRolePayload.organizer
                    case .participant:
                        Components.Schemas.CreateAccountInput.RequestedRolePayload.participant
                    case .none:
                        nil
                    }
                    let sessionDto = try await api.createAccount(.init(body: .json(.init(requestedRole: role)))).ok.body.json
                    let session = Session(sessionDto)
                    sessionCache.updateSession(session)
                    return session
                }
            },
            sessionChangedListener: {
                sessionCache.sessionChangedListener()
                
            },
            joinEvent: { pinCode in
                do {
                    return try await withAuthorization {
                        
                        let response = try await api.joinEvent(.init(path: .init(pinCode: pinCode)))
                        
                        switch response {
                        case .ok(let output):
                            let participantEvent = try output.body.json
                            sessionCache.updateOrAppendParticipantEvent(ParticipantEvent(participantEvent))
                        case .internalServerError(let internalError):
                            let apiErrorDto = try internalError.body.json
                            throw ApiError(apiErrorDto: apiErrorDto)
                        case .undocumented(statusCode: _, _):
                            throw URLError(.unknown)
                        }
                    }
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
            updateAccountRole: { role in
                let role: Components.Schemas.UpdateRoleInput.RolePayload =
                switch role {
                case .organizer:
                    Components.Schemas.UpdateRoleInput.RolePayload.organizer
                case .participant:
                    Components.Schemas.UpdateRoleInput.RolePayload.participant
                }
                try await withAuthorization(forceRefreshAfter: true) {
                    _ = try await api.updateRole(.init(body: .json(.init(role: role))))
                    return ()
                }
            },
            getMockToken: {
                return try await api.mockIdToken(body: .json(.init(role: .organizer))).ok.body.json.token
            }
        )
    }
}

public struct ApiError: Error {
    let timestamp: String?
    let message: String?
    let domainCode: DomainCode?
    let exceptionType: String?
    let path: String?
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




public enum DomainCode {
    case feedbackAlreadySubmitted, eventAlreadyJoined
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
