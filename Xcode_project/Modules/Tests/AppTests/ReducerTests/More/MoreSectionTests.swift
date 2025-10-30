@testable import MoreFeature
import Testing
import ComposableArchitecture
import Foundation
import Utility

@MainActor
struct MoreSectionTests {

    @Test
    func onNotificationsButtonTap() async {
        let baseUrl = URL(string: "https://letsgrow.dk")!
        let appStoreId = "123123123"
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State(
            webBaseUrl: baseUrl,
            appStoreId: appStoreId
        )) {
            MoreSection()
        } withDependencies: {
            $0.systemClient.openAppSettings = {
                "settings_url"
            }
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onNotificationsButtonTap)
        #expect(openedUrl.value?.absoluteString == "settings_url")
    }
    
    @Test
    func onFeedbackButtonTap() async {
        let baseUrl = URL(string: "https://letsgrow.dk")!
        let appStoreId = "123123123"
        let mockEmail = "mock@mock.dk"
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State(
            webBaseUrl: baseUrl,
            appStoreId: appStoreId
        )) {
            MoreSection()
        } withDependencies: {
            $0.systemClient = .live(supportEmail: mockEmail)
            $0.openURL = .init(handler: { url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onFeedbackButtonTap)
        #expect(openedUrl.value?.absoluteString.contains("mailto:\(mockEmail)") == true)
        #expect(openedUrl.value?.absoluteString.contains("subject=Feedback") == true)
    }
    
    @Test
    func onReportBugButtonTap() async {
        let baseUrl = URL(string: "https://letsgrow.dk")!
        let appStoreId = "123123123"
        let mockEmail = "mock@mock.dk"
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State(
            webBaseUrl: baseUrl,
            appStoreId: appStoreId
        )) {
            MoreSection()
        } withDependencies: {
            $0.systemClient = .live(supportEmail: mockEmail)
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onReportBugButtonTap)
        #expect(openedUrl.value?.absoluteString.contains("mailto:\(mockEmail)") == true)
        #expect(openedUrl.value?.absoluteString.contains("subject=Bug") == true)
    }
    
    @Test
    func onSupportUsButtonTap() async {
        let baseUrl = URL(string: "https://letsgrow.dk")!
        let appStoreId = "123123123"
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(
            initialState: MoreSection.State(
                webBaseUrl: baseUrl,
                appStoreId: appStoreId
            )
        ) {
            MoreSection()
        } withDependencies: {
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onSupportUsButtonTap)
        #expect(openedUrl.value == URL(string: "https://apps.apple.com/app/id123123123?action=write-review")!)
    }
}
