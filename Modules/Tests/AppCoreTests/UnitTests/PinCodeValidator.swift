@testable import Helpers
import Foundation
import Testing

@MainActor
struct PinCodeValidatorTests {
    
    @Test func validPinCode() async throws {
        #expect(PinCodeValidator.isValidPinCode("1234") == true)
        #expect(PinCodeValidator.isValidPinCode("123") == false)
        #expect(PinCodeValidator.isValidPinCode("12345") == false)
        #expect(PinCodeValidator.isValidPinCode("123a") == false)
        #expect(PinCodeValidator.isValidPinCode("a") == false)
    }
}
