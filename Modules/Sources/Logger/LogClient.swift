import Foundation
import ComposableArchitecture

@DependencyClient
public struct LogClient: Sendable {
    @DependencyEndpoint
    public var addLogClient: @Sendable (_ client: LoggingClient) -> Void
    var _log: @Sendable (SeverityLevel, String, CustomStringConvertible?) -> Void
}

public extension LogClient {
    func log(
        _ level: SeverityLevel,
        _ log: String,
        _ context: CustomStringConvertible? = nil
    ) {
        _log(level, log, context)
    }
    func log(_ log: String, context: CustomStringConvertible? = nil) {
        _log(.default, log, context)
    }
}

public extension LogClient {
    static let live = LogClient(
        addLogClient: { loggingClient in
            LogManager.addLogClient(loggingClient)
        },
        _log: { level, log, context in
            LogManager.log(level, log: log, context: context)
        }
    )
}

extension LogClient: TestDependencyKey {
    
    public static let previewValue = LogClient.noop
    public static let testValue = LogClient.noop
}

extension LogClient {
    public static let noop = LogClient(addLogClient: { _ in }, _log: { _, _, _ in })
}

public extension DependencyValues {
    var logClient: LogClient {
        get { self[LogClient.self] }
        set { self[LogClient.self] = newValue }
    }
}

actor LogManager {
    private static var logClients: [LoggingClient] = []
    
    static func addLogClient(_ client: LoggingClient) {
        logClients.append(client)
    }
    
    static func log(_ level: SeverityLevel, log: String, context: CustomStringConvertible? = nil) {
        for client in logClients {
            client.log(level: level, message: log, context: context)
        }
    }
}
