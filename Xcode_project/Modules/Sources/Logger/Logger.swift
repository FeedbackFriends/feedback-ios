import Foundation


public enum Logger {
    nonisolated(unsafe) private static var logClients: [LoggingClient] = []
    
    public static func setup(logClients: [LoggingClient]) {
        for client in logClients {
            Logger.logClients.append(client)
        }
    }
    
    public static func log(
        _ level: SeverityLevel,
        _ log: String,
        _ context: CustomStringConvertible? = nil,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line
    ) {
        for client in logClients {
            client.log(
                level: level,
                message: log,
                context: context,
                file: file,
                function: function,
                line: line
            )
        }
    }
    
    public static func debug(
        _ message: String,
        _ context: CustomStringConvertible? = nil,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line
    ) {
        for client in logClients {
            client.log(
                level: .debug,
                message: message,
                context: context,
                file: file,
                function: function,
                line: line
            )
        }
    }
}
