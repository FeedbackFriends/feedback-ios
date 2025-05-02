import SwiftUI
import Helpers

public extension View {
    func pinCodeInputValidation(pinCodeInput: Binding<PinCodeInput>) -> some View {
        self.modifier(PinCodeInputValidationModifier(pinCodeInput: pinCodeInput))
    }
}

struct PinCodeInputValidationModifier: ViewModifier {
    
    @Binding var pinCodeInput: PinCodeInput
    
    func body(content: Content) -> some View {
        content
            .onChange(of: pinCodeInput) { oldValue, newValue in
                if !newValue.isValidInput()  {
                    self.pinCodeInput.value.removeLast()
                }
            }
    }
}

