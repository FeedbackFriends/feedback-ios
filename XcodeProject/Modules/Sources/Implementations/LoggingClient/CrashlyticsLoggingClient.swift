import FirebaseCrashlytics
import Logger

public struct CrashlyticsLoggingClient: LoggingClient {
    public func log(
        level: SeverityLevel,
        message: String,
        context: (any CustomStringConvertible)?,
        file: String,
        function: String,
        line: Int
    ) {
        if let context = context {
            Crashlytics.crashlytics().setCustomValue(context, forKey: "context")
        }
        if level >= minLevel  {
            let error = NSError(
                domain: NSCocoaErrorDomain,
                code: -1001,
                userInfo: [
                    "log": message,
                    "file": file,
                    "function": function,
                    "line": line
                ]
            )
            Crashlytics.crashlytics().record(error: error)
        } else {
            Crashlytics.crashlytics().log(message)
        }
    }
    
    let minLevel: SeverityLevel
    init(minLevel: SeverityLevel) {
        self.minLevel = minLevel
    }
    func onStart(deviceId: String)  {
        Crashlytics.crashlytics().setUserID(deviceId)
    }
}
