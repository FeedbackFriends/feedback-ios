import SwiftUI

struct FadeInOutOnChange<T: Equatable>: ViewModifier {
    @State private var opacity: Double = 1
    let trigger: T
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onChange(of: trigger) { _, _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        opacity = 1
                    }
                }
            }
    }
}

public extension View {
    func fadeInOut<T: Equatable>(onChangeOf trigger: T) -> some View {
        self.modifier(FadeInOutOnChange(trigger: trigger))
    }
}
