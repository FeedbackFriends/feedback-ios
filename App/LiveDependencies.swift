import DependencyClients
import ComposableArchitecture
import Foundation
import DesignSystem
import APIClient

let isMock = false

extension FirebaseClient: @retroactive DependencyKey {
    public static var liveValue:  FirebaseClient {
        if isMock {
            return .mock
        }
        return .live
    }
}

extension APIClient: @retroactive DependencyKey {
    public static var liveValue: APIClient {
        if isMock {
            return .mock
        }
        return .live(
            baseUrl: URL(string: "\(infoPlist.API_SCHEME)://\(infoPlist.API_BASE_URL)")!,
            deviceId: UUID()
        )
    }
}

extension SystemClient: @retroactive DependencyKey {
    public static var liveValue: SystemClient { .live }
}
