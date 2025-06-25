import ComposableArchitecture
import Foundation
import UIKit

public extension DependencyValues {
    var systemClient: SystemClient {
        get { self[SystemClient.self] }
        set { self[SystemClient.self] = newValue }
    }
}

extension SystemClient: TestDependencyKey {
    public static let testValue = SystemClient()
    public static let previewValue = SystemClient()
}
