import Foundation
import ComposableArchitecture

@DependencyClient
public struct LogClient {
    public var addLogClient: (_ client: LoggingClient) -> Void
    var _log: (SeverityLevel, String, CustomStringConvertible?) -> Void
    public func log(
        _ level: SeverityLevel,
        _ log: String,
        _ context: CustomStringConvertible? = nil
    ) {
        _log(level, log, context)
    }
}

public extension LogClient {
    func log(_ log: String, context: CustomStringConvertible? = nil) {
        _log(.default, log, context)
    }
    func addOSLogClient(subsystem: String, category: String) {
        let osLogClient = OSLogClient(subsystem: subsystem, category: category)
        LogManager.addLogClient(osLogClient)
    }
    func addCrashlyticsClient(deviceId: String, minLevel: SeverityLevel) {
        let crashlyticsClient = CrashlyticsClient(minLevel: minLevel)
        crashlyticsClient.onStart(deviceId: deviceId)
        LogManager.addLogClient(crashlyticsClient)
    }
}

extension LogClient: DependencyKey {
    public static let liveValue = LogClient(
        addLogClient: { loggingClient in
            LogManager.addLogClient(loggingClient)
        },
        _log: { level, log, context in
            LogManager.log(level, log: log, context: context)
        }
    )
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

final class LogManager {
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
