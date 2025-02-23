import OSLog

struct OSLogClient: LoggingClient {
    let subsystem: String
    let category: String
    public func log(level: SeverityLevel, message: String, context: (any CustomStringConvertible)?) {
        let logger = os.Logger(subsystem: subsystem, category: category)
        var outputString: String = "\n\(level.emoji) \(message)"
        if let context = context {
            outputString.append(contentsOf: "\n\ncontext: \(context.description)")
        }
        logger.log(level: level.osLogLevel, "\(outputString)")
    }
}

