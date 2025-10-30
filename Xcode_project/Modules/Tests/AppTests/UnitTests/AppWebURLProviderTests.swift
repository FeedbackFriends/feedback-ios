@testable import Utility
import Testing
import Foundation
import Domain

 @MainActor
 class AppWebURLProviderTests {
    
    @Test
    func testInviteUrlGeneration() {
        let baseUrl = URL(string: "https://letsgrow.com")!
        let pinCode = PinCode(value: "2344")
        let inviteUrl = AppWebURLProvider.invite(forPinCode: pinCode.value, baseUrl: baseUrl)
        #expect(inviteUrl!.absoluteString == "https://letsgrow.com/invite/2344")
    }
    
    @Test
    func testPrivacyPolicyUrlGeneration() {
        let baseUrl = URL(string: "https://letsgrow.com")!
        let url = AppWebURLProvider.privacyPolicy(forBaseUrl: baseUrl)
        #expect(url.absoluteString == "https://letsgrow.com/privacy-policy/")
    }
    
    @Test
    func testAppStoreReviewUrlGeneration() {
        let appstoreId = "987654321"
        let url = AppWebURLProvider.appStoreReview(forAppStoreId: appstoreId)
        #expect(url.absoluteString == "https://apps.apple.com/app/id987654321?action=write-review")
    }
 }
