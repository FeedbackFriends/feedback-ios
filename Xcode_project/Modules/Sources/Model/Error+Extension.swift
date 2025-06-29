import Foundation

public extension Error {
	
	var localized: PresentableError {
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
		
		let nsError = self as NSError
		if let localizedMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
			message = localizedMessage
		}
		print("Error of type: \(type(of: self))/nlocalizedDescription: \(self.localizedDescription)")
		return PresentableError(title: title, message: message)
	}
}
