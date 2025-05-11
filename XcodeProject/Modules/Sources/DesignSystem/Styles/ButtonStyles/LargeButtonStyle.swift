import SwiftUI

public struct LargeButtonStyle<Input: ShapeStyle>: ButtonStyle {

    @Environment(\.isLoading) private var isLoading
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    let color: Input
    let progressViewColor: Color
    
    public init(color: Input = Color.themePrimaryAction.gradient, progressViewColor: Color = Color.white) {
        self.color = color
        self.progressViewColor = progressViewColor
    }
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .transition(.blurReplace)
                    .progressViewStyle(CircularProgressViewStyle(tint: progressViewColor))
            }
            configuration.label
        }
        .frame(maxWidth: .infinity, minHeight: 50, idealHeight: 50, maxHeight: 55, alignment: .center)
        .font(.montserratSemiBold, 16)
        .background(color)
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
