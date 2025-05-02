import Foundation

public struct UpdatedSession: Equatable, Sendable {
    public let updatedManagerEvents: [ManagerEvent]?
    public let activity: Activity
    public let recentlyUsedQuestions: Set<RecentlyUsedQuestions>?
    public init(updatedManagerEvents: [ManagerEvent]?, activity: Activity, recentlyUsedQuestions: Set<RecentlyUsedQuestions>?) {
        self.updatedManagerEvents = updatedManagerEvents
        self.activity = activity
        self.recentlyUsedQuestions = recentlyUsedQuestions
    }
}
