@testable import MoreFeature
import Testing
import ComposableArchitecture
import Foundation
import Utility

@MainActor
struct MoreSectionTests {
    
    let mockAppStoreReviewUrl = URL(string: "itms-apps://itunes.apple.com/app/id123456789")!
    let mockPrivacyPolicyUrl = URL(string: "https://letsgrow.dk/privacy-policy")!
    let mockSupportEmailAddress = "support@example.com"
    
    @Test
    func onNotificationsButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
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
        await store.send(.onAppear) {
            $0.appStoreReviewUrl = mockAppStoreReviewUrl
            $0.privacyPolicyUrl = mockPrivacyPolicyUrl
        }
        await store.send(.onNotificationsButtonTap)
        #expect(openedUrl.value?.absoluteString == "settings_url")
    }
    
    @Test
    func onFeedbackButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient = .live(supportEmail: mockSupportEmailAddress)
            $0.openURL = .init(handler: { url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onAppear) {
            $0.appStoreReviewUrl = mockAppStoreReviewUrl
            $0.privacyPolicyUrl = mockPrivacyPolicyUrl
        }
        await store.send(.onFeedbackButtonTap)
        #expect(openedUrl.value?.absoluteString.contains("mailto:\(mockSupportEmailAddress)") == true)
        #expect(openedUrl.value?.absoluteString.contains("subject=Feedback") == true)
    }
    
    @Test
    func onReportBugButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient = .live(supportEmail: mockSupportEmailAddress)
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onAppear) {
            $0.appStoreReviewUrl = mockAppStoreReviewUrl
            $0.privacyPolicyUrl = mockPrivacyPolicyUrl
        }
        await store.send(.onReportBugButtonTap)
        #expect(openedUrl.value?.absoluteString.contains("mailto:\(mockSupportEmailAddress)") == true)
        #expect(openedUrl.value?.absoluteString.contains("subject=Bug") == true)
    }
    
    @Test
    func onSupportUsButtonTap() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onAppear) {
            $0.appStoreReviewUrl = mockAppStoreReviewUrl
            $0.privacyPolicyUrl = mockPrivacyPolicyUrl
        }
        await store.send(.onSupportUsButtonTap)
        #expect(openedUrl.value == mockAppStoreReviewUrl)
    }
}
