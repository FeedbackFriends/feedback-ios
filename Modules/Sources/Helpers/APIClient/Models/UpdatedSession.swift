import Foundation

public struct UpdatedSession: Equatable, Sendable {
    public let events: [ManagerEvent]
    public let activity: Activity
    public init(events: [ManagerEvent], activity: Activity) {
        self.events = events
        self.activity = activity
    }
}

