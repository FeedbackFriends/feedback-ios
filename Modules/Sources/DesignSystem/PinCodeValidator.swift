import SwiftUI
import Foundation
import Helpers

struct PinCodeValidationModifier: ViewModifier {
    @Binding var text: String

    func body(content: Content) -> some View {
        content
            .onChange(of: text) { oldValue, newValue in
                if newValue.count > PinCodeValidator.pinMax  {
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
