import Foundation
import OpenAPIRuntime

public struct ApiError: Error, Sendable {
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

public enum DomainCode: Sendable {
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
