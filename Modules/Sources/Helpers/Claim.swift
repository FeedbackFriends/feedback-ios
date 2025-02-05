public enum Claim: String, Equatable {
    case participant, manager
    
    public var localized: String {
        switch self {
        case .participant:
            "Participant"
        case .manager:
            "Organizer"
        }
    }
}

