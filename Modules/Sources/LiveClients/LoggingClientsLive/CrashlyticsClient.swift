import FirebaseCrashlytics
import Helpers
import FirebaseCrashlytics
import Logger

struct CrashlyticsClient: LoggingClient {
    let minLevel: SeverityLevel
    func onStart(deviceId: String)  {
        Crashlytics.crashlytics().setUserID(deviceId)
    }
    public func log(level: SeverityLevel, message: String, context: (any CustomStringConvertible)?) {
        if let context = context {
            Crashlytics.crashlytics().setCustomValue(context, forKey: "context")
        }
        if level >= minLevel  {
            let error = NSError(
                domain: NSCocoaErrorDomain,
                code: -1001,
                userInfo: ["log": message]
            )
            Crashlytics.crashlytics().record(error: error)
            assertionFailure("Log above minimum level: \(level), message: \(message), context: \(context ?? "No context")")
        } else {
            Crashlytics.crashlytics().log(message)
        }
    }
}
