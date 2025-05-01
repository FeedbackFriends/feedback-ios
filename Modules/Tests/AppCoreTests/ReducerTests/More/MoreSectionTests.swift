@testable import More
import Testing
import ComposableArchitecture
import Foundation

@MainActor
struct MoreSectionTests {
    
    @Test
    func onNotificationsButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient.openSettingsURLString = { "app-settings://" }
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onNotificationsButtonTap)
        #expect(openedUrl.value?.absoluteString == "app-settings://")
    }
    
    @Test
    func onFeedbackButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient.appleMailUrl = { subject, body in
                return URL(string: "mailto:feedback@example.com?subject=\(subject)&body=\(body)")!
            }
            $0.openURL = .init(handler: { url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onFeedbackButtonTap)
        #expect(openedUrl.value?.absoluteString == "mailto:feedback@example.com?subject=Feedback,%20v16.0(23796),%20iOS%2018.4&body=")
    }
    
    @Test
    func onReportBugButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient.appleMailUrl = { subject, body in
                return URL(string: "mailto:bugreport@example.com?subject=\(subject)&body=\(body)")!
            }
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onReportBugButtonTap)
        #expect(openedUrl.value?.absoluteString == "mailto:bugreport@example.com?subject=Bug,%20v16.0(23796),%20iOS%2018.4&body=")
    }
    
    @Test
    func onSupportUsButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient.appStoreReviewUrl = {
                return URL(string: "https://appstore.com/app-review")!
            }
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onSupportUsButtonTap)
        #expect(openedUrl.value?.absoluteString == "https://appstore.com/app-review")
        
    }
    
}
