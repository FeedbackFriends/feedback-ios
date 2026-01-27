import Foundation

public struct SyncStatus: Equatable, Sendable {
    public var isSyncing: Bool
    public var lastUpdatedAt: Date?

    public init(isSyncing: Bool = false, lastUpdatedAt: Date? = nil) {
        self.isSyncing = isSyncing
        self.lastUpdatedAt = lastUpdatedAt
    }
}
