@testable import EnterCode
import Testing
import ComposableArchitecture
import Foundation

@MainActor
struct EnterCodeTests {
    
    @Test
    func startFeedback() async {
        let store = TestStore(initialState: EnterCode.State(inputCode: "1234")) {
            EnterCode()
        }
        
        await store.send(.startFeedbackButtonTap) {
            $0.startFeedbackPincodeInFlight = true
            $0.inputCode = ""
        }
        
        await store.receive(\.delegate, .startFeedback(pinCode: "1234"))
    }
}
