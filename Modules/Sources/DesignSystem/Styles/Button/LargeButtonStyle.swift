import SwiftUI

public struct LargeButtonStyle<Input: ShapeStyle>: ButtonStyle {

    @Environment(\.isLoading) private var isLoading
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    let color: Input
    
    
    public init(color: Input = Color.themePrimaryAction.gradient) {
        self.color = color
    }
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .transition(.blurReplace)
            }
            configuration.label
        }
        .frame(maxWidth: .infinity, minHeight: 50, idealHeight: 50, maxHeight: 55, alignment: .center)
        .font(.montserratSemiBold, 16)
        .background(color)
        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
        .multilineTextAlignment(.center)
        .opacity(isEnabled ? 1.0 : 0.5)
        .foregroundColor(.themeWhite)
        .animation(.default, value: isEnabled)
        .animation(.default, value: isLoading)
        .clipShape(Capsule(style: .continuous))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}
