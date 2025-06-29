import ComposableArchitecture
import Foundation
import Model
import UIKit
import Mocks

extension SystemClient: TestDependencyKey {
    public static let testValue = SystemClient()
    public static let previewValue = SystemClient()
}
