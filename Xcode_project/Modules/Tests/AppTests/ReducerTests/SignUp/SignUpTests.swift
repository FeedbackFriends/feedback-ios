@testable import SignUpFeature
import Testing
import ComposableArchitecture
import Domain

struct SignUpTests {
    enum TestError: Error, Equatable { case mock }
    
    @Test
    func signUpWithApple_success() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.appleLogin = { () }
        }

        await store.send(.signUpWithAppleButtonTap) {
            $0.appleLoginInFlight = true
        }
        await store.receive(\.signUpSuccess) {
            $0.appleLoginInFlight = false
        }
    }

    @Test
    func signUpWithGoogle_success() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.googleLogin = { () }
        }

        await store.send(.signUpWithGoogleButtonTap) {
            $0.googleLoginInFlight = true
        }
        await store.receive(\.signUpSuccess) {
            $0.googleLoginInFlight = false
        }
    }

    @Test
    func signUpWithApple_cancelled() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.appleLogin = { throw AuthenticationError.loginCancelled }
        }
        await store.send(.signUpWithAppleButtonTap) {
            $0.appleLoginInFlight = true
        }
        await store.receive(\.loginCancelled) {
            $0.appleLoginInFlight = false
        }
    }

    @Test
    func signUpWithGoogle_cancelled() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.googleLogin = { throw AuthenticationError.loginCancelled }
        }

        await store.send(.signUpWithGoogleButtonTap) {
            $0.googleLoginInFlight = true
        }
        await store.receive(\.loginCancelled) {
            $0.googleLoginInFlight = false
        }
    }

    @Test
    func signUpWithApple_failure() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.appleLogin = { throw TestError.mock }
        }

        await store.send(.signUpWithAppleButtonTap) {
            $0.appleLoginInFlight = true
        }
        await store.receive(\.presentError) {
            $0.destination = .alert(.init(error: TestError.mock))
            $0.appleLoginInFlight = false
        }
    }

    @Test
    func signUpWithGoogle_failure() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.googleLogin = { throw TestError.mock }
        }

        await store.send(.signUpWithGoogleButtonTap) {
            $0.googleLoginInFlight = true
        }
        await store.receive(\.presentError) {
            $0.destination = .alert(.init(error: TestError.mock))
            $0.googleLoginInFlight = false
        }
    }
}
