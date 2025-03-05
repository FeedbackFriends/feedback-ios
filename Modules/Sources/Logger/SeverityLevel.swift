import OSLog
import Dependencies

public enum SeverityLevel: Sendable {
    case info
    case `default`
    case debug
    case error
    case fault
}

extension SeverityLevel: Comparable {
    var levelValue: Int {
        switch self {
        case .info:     return 0
        case .`default`:  return 1
        case .debug:    return 1
        case .error:    return 2
        case .fault:    return 3
        }
    }
    
    public static func < (lhs: SeverityLevel, rhs: SeverityLevel) -> Bool {
        return lhs.levelValue < rhs.levelValue
    }
}

extension SeverityLevel {
    var emoji: String {
        switch self {
        case .fault: return "🔴"
        case .error: return "🟠"
        default: return "🔵"
        }
    }
}

public extension SeverityLevel {
    var osLogLevel: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .error:
            return .error
        case .fault:
            return .fault
        default:
            return .default
        }
    }
}
