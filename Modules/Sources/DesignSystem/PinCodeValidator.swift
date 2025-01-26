import SwiftUI
import Foundation

let pinMax = 4

struct PinCodeValidationModifier: ViewModifier {
    @Binding var text: String

    func body(content: Content) -> some View {
        content
            .onChange(of: text) { oldValue, newValue in
                if newValue.count > pinMax  {
                    self.text.removeLast()
                }
            }
    }
}

public extension View {
    func pinCodeValidation(text: Binding<String>) -> some View {
        self.modifier(PinCodeValidationModifier(text: text))
    }
}

public struct PinCodeValidator {
    public static func isValidPinCode(_ pinCode: String) -> Bool {
        return pinCode.count == pinMax && pinCode.allSatisfy { $0.isNumber }
    }
}
