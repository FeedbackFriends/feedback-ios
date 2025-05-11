@testable import MoreFeature
import Testing
import ComposableArchitecture
import Foundation
import Utility

@MainActor
struct MoreSectionTests {
    
    @Test
    func onNotificationsButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient = .live(
                webUrl: URL(string: "https://test.dk")!,
                appstoreId: "my_id",
                supportEmail: "feedback@example.com"
            )
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onNotificationsButtonTap)
        #expect(openedUrl.value?.absoluteString == "app-settings:")
    }
    
    @Test
    func onFeedbackButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient = .live(
                webUrl: URL(string: "https://test.dk")!,
                appstoreId: "my_id",
                supportEmail: "feedback@example.com"
            )
            $0.openURL = .init(handler: { url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onFeedbackButtonTap)
        #expect(openedUrl.value?.absoluteString.contains("mailto:feedback@example.com") == true)
        #expect(openedUrl.value?.absoluteString.contains("subject=Feedback") == true)
    }
    
    @Test
    func onReportBugButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient = .live(
                webUrl: URL(string: "https://test.dk")!,
                appstoreId: "my_id",
                supportEmail: "feedback@example.com"
            )
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onReportBugButtonTap)
        #expect(openedUrl.value?.absoluteString.contains("mailto:feedback@example.com") == true)
        #expect(openedUrl.value?.absoluteString.contains("subject=Bug") == true)
    }
    
    @Test
    func onSupportUsButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient = .live(
                webUrl: URL(string: "https://test.dk")!,
                appstoreId: "my_id",
                supportEmail: "feedback@example.com"
            )
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onSupportUsButtonTap)
        #expect(openedUrl.value?.absoluteString == "https://apps.apple.com/app/idmy_id?action=write-review")
    }
    
}
