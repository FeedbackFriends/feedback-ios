import ComposableArchitecture
import Foundation

public extension AlertState {
    init(error: Error) {
        
        let alert: AlertState<Action>
        
        var defaultErrorAlert: AlertState<Action> = AlertState(
            title: { TextState(error.localized.title) },
            message: { TextState(error.localized.message) }
        )
        defaultErrorAlert.buttons.append(ButtonState(role: .cancel, action: .send(.none), label: { TextState("Ok") }))
        alert = defaultErrorAlert
        self = alert
    }
}

public extension Error {
    
    var localized: LocalizedError {
        var title: String = "Something Went Wrong"
        var message: String = "An unexpected issue occurred."
        if let apiError = self as? ApiError, let domainError = apiError.domainCode {
            switch domainError {
            case .feedbackAlreadySubmitted:
                title = "Error"
                message = "Feedback already submitted for this event."
            case .eventAlreadyJoined:
                title = "Error"
                message = "You already joined this event."
            }
        }
        if let urlError = self as? URLError {
            message = urlError.localizedDescription
        }
        return LocalizedError(title: title, message: message)
    }
}

public struct LocalizedError {
    public let title: String
    public let message: String
}
