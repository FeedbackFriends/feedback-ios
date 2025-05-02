public protocol LoggingClient {
    func log(level: SeverityLevel, message: String, context: CustomStringConvertible?) -> Void
}
