import Logger

public extension CrashlyticsLoggingClient {
    static func create(deviceId: String, minLevel: SeverityLevel) -> CrashlyticsLoggingClient {
        let CrashlyticsLoggingClient = CrashlyticsLoggingClient(minLevel: minLevel)
        CrashlyticsLoggingClient.onStart(deviceId: deviceId)
        return CrashlyticsLoggingClient
    }
}
