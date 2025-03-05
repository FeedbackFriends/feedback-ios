//@testable import SignUp
//
//import Helpers
//import Combine
//import ComposableArchitecture
//import XCTest
//
//@MainActor
//final class LoginTests: XCTestCase {
//    
//    func test_navigation_welcome_signup() async {
//        let clock = TestClock()
//        let vm = withDependencies {
//            $0.continuousClock = clock
//        } operation: {
//            SignUpViewModel()
//        }
//        XCTAssertFalse(vm.viewDidLoad)
//        vm.onLoad()
//        XCTAssertTrue(vm.viewDidLoad)
//        XCTAssertFalse(vm.viewDidAppearDelay)
//        await clock.advance(by: .seconds(1))
//        XCTAssertTrue(vm.viewDidAppearDelay)
//        vm.onContinueButtonTap()
//        XCTAssertTrue(vm.navigateToSignUp)
//        vm.onBackButtonTap()
//        XCTAssertEqual(vm.navigateToSignUp, false)
//    }
//    
//    func test_google_login() async throws {
//        
//        let publisher = PassthroughSubject<(String?), Never>()
//        let googleLoginTriggered = ActorIsolated<Bool>(false)
//        let clock = TestClock()
//        
//        let vm = withDependencies {
//            $0.authClient.onTokenChange = { publisher }
//            $0.authClient.googleLogin = {
//                struct GoogleError: Error {}
//                await googleLoginTriggered.setValue(true)
//                throw GoogleError()
//            }
//            $0.persistenceClient.meetingManagerEnabled = .init(load: { true }, save: { _ in })
//            $0.continuousClock = clock
//        } operation: {
//            SignUpViewModel(selectedUserType: .feedbackOnly, navigateToSignUp: true)
//        }
//        await googleLoginTriggered.withValue {
//            XCTAssertFalse($0)
//        }
//        vm.googleSignInButtonTapped()
//        await clock.advance()
//        await googleLoginTriggered.withValue {
//            XCTAssertTrue($0)
//        }
//        XCTAssertNotNil(vm.alert)
//    }
//
//    func test_microsoft_login() async throws {
//        
//        let publisher = PassthroughSubject<(String?), Never>()
//        let microsoftLoginTriggered = ActorIsolated<Bool>(false)
//        let clock = TestClock()
//        
//        let vm = withDependencies {
//            $0.authClient.onTokenChange = { publisher }
//            $0.authClient.microsoftLogin = {
//                struct MicrosoftError: Error {}
//                await microsoftLoginTriggered.setValue(true)
//                throw MicrosoftError()
//            }
//            $0.persistenceClient.meetingManagerEnabled = .init(load: { true }, save: { _ in })
//            $0.continuousClock = clock
//        } operation: {
//            SignUpViewModel(selectedUserType: .feedbackOnly, navigateToSignUp: true)
//        }
//        await microsoftLoginTriggered.withValue {
//            XCTAssertFalse($0)
//        }
//        vm.microsoftSignInButtonTapped()
//        await clock.advance()
//        await microsoftLoginTriggered.withValue {
//            XCTAssertTrue($0)
//        }
//        XCTAssertNotNil(vm.alert)
//    }
//}
