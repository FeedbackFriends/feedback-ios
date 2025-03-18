import Foundation
import Logger

public extension LogClient {

    func addOSLogClient(subsystem: String, category: String) {
        let osLogClient = OSLogClient(subsystem: subsystem, category: category)
        self.addLogClient(client: osLogClient)
    }
    func addCrashlyticsClient(deviceId: String, minLevel: SeverityLevel) {
        let crashlyticsClient = CrashlyticsClient(minLevel: minLevel)
        crashlyticsClient.onStart(deviceId: deviceId)
        self.addLogClient(client: crashlyticsClient)
    }
}
