import Logger

public extension CrashlyticsLoggingClient {
    static func create(deviceId: String, minLevel: SeverityLevel) -> CrashlyticsLoggingClient {
        let crashlyticsLoggingClient = CrashlyticsLoggingClient(minLevel: minLevel)
        crashlyticsLoggingClient.onStart(deviceId: deviceId)
        return crashlyticsLoggingClient
    }
}
