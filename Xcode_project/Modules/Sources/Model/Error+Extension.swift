import Foundation
import Logger

public extension Error {
	
	var localized: PresentableError {
		var title: String = "Error 💩"
		var message: String = "An unexpected issue occurred. Try again."
		if let apiError = self as? ApiError, let domainError = apiError.domainCode {
			switch domainError {
			case .feedbackAlreadySubmitted:
				message = "Feedback already submitted for this event."
			case .eventAlreadyJoined:
				message = "You already joined this event."
            case .pincodeNotFound:
                message = "The provided pin code does not match any active event."
            case .eventAlreadyJoined:
                message = "You already joined this event."
            case .cannotJoinOwnEvent:
                message = "You cannot join your own event."
            case .cannotGiveFeedbackToSelf:
                message = "You cannot give feedback to yourself."
            }
		}
		if let urlError = self as? URLError {
			message = urlError.localizedDescription
		}
		
		let nsError = self as NSError
		if let localizedMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
			message = localizedMessage
		}
		Logger.debug("Error of type: \(type(of: self))/nlocalizedDescription: \(self.localizedDescription)")
		return PresentableError(title: title, message: message)
	}
}
