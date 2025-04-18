//import Foundation
//import ComposableArchitecture
//import UIKit
//import SnapshotTesting
//import Testing
//import SwiftUI
//import Helpers
//
//@testable import AppCore
//@testable import EventsFeature
//
//extension Snapshotting where Value: UIViewController, Format == UIImage {
//    @MainActor
//    static func windowedImage(precision: Float = 1) -> Snapshotting {
//        Snapshotting<UIImage, UIImage>.image(precision: precision, perceptualPrecision: precision).asyncPullback { vc in
//            Async<UIImage> { callback in
//                guard
//                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                    let window = windowScene.windows.first
//                else {
//                    return
//                }
//                window.rootViewController = vc
//                window.layer.speed = 100
//                DispatchQueue.main.async {
//                    let image = UIGraphicsImageRenderer(bounds: window.bounds).image { ctx in
//                        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
//                    }
//                    callback(image)
//                }
//            }
//        }
//    }
//    
//    @MainActor
//    static func windowedImageWithDelay(
//        seconds duration: TimeInterval = 0.2,
//        precision: Float = 1
//    ) -> Snapshotting<Value, Format> {
//        wait(for: duration, on: .windowedImage(precision: precision))
//    }
//}
//
//// MARK: - Test example
//
//@MainActor
//class Tests {
//
//@Test
//func test_creatingNewMeasuredRecordFromOverviewTab() async {
//    let session = NewSession.mock()
//    let store = Store(
//        initialState: ManagerEvents.State(session: .init(value: session)),
//        reducer: { ManagerEvents()
//        },
//        withDependencies: {
//            $0.apiClient = .mock()
//            $0.systemClient = SystemClient(
//                setUserInterfaceStyle: { _ in },
//                hideKeyboard: {},
//                openSettingsURLString: { "https://letsgrow.dk" },
//                inviteUrl: { _ in URL(string: "https://letsgrow.dk")! },
//                privacyPolicyUrl: { URL(string: "https://letsgrow.dk")! },
//                appleMailUrl: { _,_ in URL(string: "https://letsgrow.dk")! },
//                appStoreReviewUrl: { URL(string: "https://letsgrow.dk")! }
//            )
//        }
//    )
//    let vc = NavigationStack { ManagerEventsView(store: store) }.toViewController()
//    // 1. Show empty App feature first
//    assertSnapshot(of: vc, as: .windowedImageWithDelay(), record: true)
//    // 2. Show new measured place feature and wait for the text field focus
//    store.send(.managerEventTap(session.managerData!.managerEvents.first!))
//    assertSnapshot(of: vc, as: .windowedImageWithDelay(), record: true)
////
////    // 3. Add button triggers alert if value is zero
//    store.send(.destination(.presented(.eventDetail(.moreButtonTapped))))
//    assertSnapshot(of: vc, as: .windowedImageWithDelay(), record: true)
//    
//    store.send(.destination(.presented(.eventDetail(.destination(.presented(.confirmationDialog(.invite)))))))
//    assertSnapshot(of: vc, as: .windowedImageWithDelay(), record: true)
////
////    // 4. Dismiss alert
////    store.send(.app(.overview(.destination(.presented(.newMeasuredRecord(.destination(.dismiss)))))))
////    assertSnapshot(of: vc, as: .windowedImageWithDelay())
////    ​
////    // 5. Fill the value
////    store.send(.app(.overview(.destination(.presented(.newMeasuredRecord(.valueInput(.view(.binding(.set(\.value, "123"))))))))))
////    assertSnapshot(of: vc, as: .windowedImageWithDelay())
////    ​
////    // 6. Add button saves new record and dismiss
////    store.send(.app(.overview(.destination(.presented(.newMeasuredRecord(.view(.addButtonTapped)))))))
////    assertSnapshot(of: vc, as: .windowedImageWithDelay())
//}
//
//}
//
//extension SwiftUI.View {
//    func toViewController() -> UIViewController {
//        let viewController = UIHostingController(rootView: self)
//        viewController.view.frame = UIScreen.main.bounds
//        return viewController
//    }
//}
