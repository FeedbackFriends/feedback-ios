public enum Role: String, Equatable, Sendable {
    case participant, organizer
    
    public var localized: String {
        switch self {
        case .participant:
            "Participant"
        case .organizer:
            "Organizer"
        }
    }
}

