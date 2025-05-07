@testable import TabbarFeature
import ComposableArchitecture
import Testing
import Foundation
import Model

@MainActor
struct DeleteAccountTests {

    @Test
    func testConfirmDeleteSuccessFlow() async {
        let store = TestStore(initialState: .init()) {
            DeleteAccount()
        } withDependencies: {
            $0.apiClient.deleteAccount = { () }
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.deleteAccountButtonTapped) {
            $0.destination = .alert(
                AlertState(
                    title: { TextState("Are you sure?") },
                    actions: {
                        ButtonState(role: .destructive, action: .confirmedToDeleteAccount, label: { TextState("Delete account") })
                        ButtonState(role: .cancel, label: { TextState("Cancel") })
                    },
                    message: { TextState("All data related to your account will be deleted and cannot be restored. ⚠️") }
                )
            )
        }

        await store.send(.destination(.presented(.alert(.confirmedToDeleteAccount)))) {
            $0.deleteAccountInFlight = true
            $0.destination = nil
        }

        await store.receive(\.accountSuccesfullyDeleted) {
            $0.deleteAccountInFlight = false
            $0.destination = .alert(
                AlertState(
                    title: { TextState("Account deleted.") },
                    actions: {
                        ButtonState(role: .cancel, action: .send(.closeSessionButtonTap), label: { TextState("Close") })
                    },
                    message: { TextState("Thank you for using Lets Grow.") }
                )
            )
        }
    }

    @Test
    func testDeleteFailurePresentsError() async {
        let error = URLError(.cannotConnectToHost)
        let store = TestStore(initialState: .init()) {
            DeleteAccount()
        } withDependencies: {
            $0.apiClient.deleteAccount = { throw error }
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.deleteAccountButtonTapped) {
            $0.destination = .alert(
                .init(
                    title: { TextState("Are you sure?") },
                    actions: {
                        ButtonState(
                            role: .destructive,
                            action: .confirmedToDeleteAccount,
                            label: { TextState("Delete account") }
                        )
                        ButtonState(
                            role: .cancel,
                            label: { TextState("Cancel") }
                        )
                    },
                    message: { TextState("All data related to your account will be deleted and cannot be restored. ⚠️") }
                )
            )
        }
        await store.send(.destination(.presented(.alert(.confirmedToDeleteAccount)))) {
            $0.deleteAccountInFlight = true
            $0.destination = nil
        }

        await store.receive(\.presentError) {
            $0.deleteAccountInFlight = false
            $0.destination = .alert(.init(error: error))
        }
    }

    @Test
    func testLogoutFailureShowsRetryAlert() async {
        let store = TestStore(initialState: .init(
            destination: .alert(AlertState(title: { TextState("Account deleted.") }))
        )) {
            DeleteAccount()
        } withDependencies: {
            $0.authClient.logout = { throw URLError(.timedOut) }
        }

        await store.send(.destination(.presented(.alert(.closeSessionButtonTap)))) {
            $0.destination = nil
        }
        await store.receive(\.logoutFailed) {
            $0.destination = .alert(
                AlertState(
                    title: { TextState("Logout failed.") },
                    actions: {
                        ButtonState(action: .send(.logout), label: { TextState("Log out") })
                    },
                    message: { TextState("Please try again.") }
                )
            )
        }
    }

    @Test
    func testLogoutRetrySucceeds() async {
        let store = TestStore(initialState: .init(
            destination: .alert(AlertState(title: { TextState("Logout failed.") }))
        )) {
            DeleteAccount()
        } withDependencies: {
            $0.authClient.logout = { /* success */ }
        }
        
        await store.send(.destination(.presented(.alert(.logout)))) {
            $0.destination = nil
        }
        // No follow-up receive
        // Navigation happens automatically from AppCore where stream is triggered by firebase
    }
}
