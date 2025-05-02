import Foundation

public struct UpdatedSession: Equatable, Sendable {
    public let updatedManagerEvents: [ManagerEvent]?
    public let activity: Activity
    public init(updatedManagerEvents: [ManagerEvent]?, activity: Activity) {
        self.updatedManagerEvents = updatedManagerEvents
        self.activity = activity
    }
}
