@testable import MoreFeature
import Testing
import ComposableArchitecture
import Foundation

@MainActor
struct ModifyAccountTests {
    
    @Test
    func saveButtonTapSuccess() async {
        let dismissed = LockIsolated(false)
        let store = TestStore(initialState: ModifyAccount.State(
            nameInput: "John Doe",
            emailInput: "john.doe@example.com",
            phoneNumberInput: "1234567890"
        )) {
            ModifyAccount()
        } withDependencies: {
            $0.apiClient.updateAccount = { _, _, _ in }
            $0.dismiss = .init({
                dismissed.setValue(true)
            })
        }
        await store.send(.saveButtonTap) {
            $0.isLoading = true
        }
        await store.receive(\.updateAccountResponse) {
            $0.isLoading = false
        }
        #expect(dismissed.value == true)
    }
    
    @Test
    func saveButtonTapFailure() async {
        struct Failure: Error, Equatable {}
        
        let store = TestStore(initialState: ModifyAccount.State(
            nameInput: "John Doe",
            emailInput: "john.doe@example.com",
            phoneNumberInput: "1234567890"
        )) {
            ModifyAccount()
        } withDependencies: {
            $0.apiClient.updateAccount = { _, _, _ in throw Failure() }
        }
        await store.send(.saveButtonTap) {
            $0.isLoading = true
        }
        await store.receive(\.presentError) {
            $0.isLoading = false
            $0.destination = .alert(.init(error: Failure()))
        }
    }
}
