import DependencyClients
import ComposableArchitecture
import Foundation
import DesignSystem
import APIClient

let compilerFlag = AppConfiguration.compilerFlag

var isMock: Bool {
    switch compilerFlag {
    case .TEST, .RELEASE, .DEBUG:
        return false
    case .MOCK:
            return true
    }
}

extension FirebaseClient: @retroactive DependencyKey {
    public static var liveValue:  FirebaseClient {
        if isMock {
            fatalError()
//            return .live
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
            baseUrl: URL(string: "http://localhost:8080")!,
//                baseUrl: URL(string: "http://51.195.40.155:8080")!,
            deviceId: UUID()
        )
    }
}

extension SystemClient: @retroactive DependencyKey {
    public static var liveValue: SystemClient { .live }
}
