@testable import MoreFeature
import Testing
import ComposableArchitecture
import Foundation
import Utility
import Domain

@MainActor
struct MoreSectionTests {
    
    nonisolated let mockConfiguration = AppConfiguration(
        webBaseUrl: URL(string: "https://letsgrow.dk")!,
        appStoreId: "123456789",
        supportEmail: "mock@mock.dk"
    )
    
    @Test
    func onNotificationsButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient.openAppSettings = {
                "settings_url"
            }
            $0.systemClient.configuration = { mockConfiguration }
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
        let mockEmail = "mock@mock.dk"
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient.configuration = { mockConfiguration }
            $0.openURL = .init(handler: { url in
                openedUrl.setValue(url)
                return true
            })
            $0.systemClient.openEmail = { _, _ in
                var components = URLComponents(string: "mailto:mock@mock.dk")!
                components.queryItems = [
                    URLQueryItem(name: "subject", value: "mock"),
                    URLQueryItem(name: "body", value: "mock")
                ]
                return components.url!
            }
        }
        await store.send(.onFeedbackButtonTap)
        #expect(openedUrl.value?.absoluteString.contains("mailto:\(mockEmail)") == true)
        #expect(openedUrl.value?.absoluteString.contains("mailto:mock@mock.dk") == true)
    }
    
    @Test
    func onReportBugButtonTap() async {
        let mockEmail = "mock@mock.dk"
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient.configuration = { mockConfiguration }
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
            $0.systemClient.openEmail = { _, _ in
                var components = URLComponents(string: "mailto:mock@mock.dk")!
                components.queryItems = [
                    URLQueryItem(name: "subject", value: "mock"),
                    URLQueryItem(name: "body", value: "mock")
                ]
                return components.url!
            }
        }
        await store.send(.onReportBugButtonTap)
        #expect(openedUrl.value?.absoluteString.contains("mailto:\(mockEmail)") == true)
        #expect(openedUrl.value?.absoluteString.contains("subject=mock") == true)
        #expect(openedUrl.value?.absoluteString.contains("body=mock") == true)
    }
    
    @Test
    func onSupportUsButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(
            initialState: MoreSection.State()
        ) {
            MoreSection()
        } withDependencies: {
            $0.systemClient.configuration = { mockConfiguration }
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onSupportUsButtonTap)
        #expect(openedUrl.value == URL(string: "https://apps.apple.com/app/id123456789?action=write-review")!)
    }
}
