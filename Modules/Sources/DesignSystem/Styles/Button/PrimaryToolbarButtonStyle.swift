import SwiftUI

public struct PrimaryToolbarButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isLoading) private var isLoading
    private var color: Color
    
    public init(color: Color = Color.themePrimaryAction) {
        self.color = color
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .transition(.blurReplace)
            } else {
                configuration.label
            }
        }
        .animation(.bouncy, value: isLoading)
        .font(.montserratBold, 15)
        .foregroundStyle(isEnabled ? color : Color.themeDarkGray.opacity(0.5))
        .opacity(isEnabled ? 1.0 : 0.5)
        .progressViewStyle(CircularProgressViewStyle(tint: Color.themeDarkGray))
        .opacity(configuration.isPressed ? 0.5 : 1)
        .animation(.default, value: isEnabled)
    }
}
