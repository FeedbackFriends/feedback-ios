import SwiftUI

public struct PrimaryTextButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isLoading) private var isLoading
    private let color: Color
	
	var foregroundColor: Color {
		isEnabled ? color : Color.themeText.opacity(0.5)
	}
    
    public init(color: Color = Color.themePrimaryAction) {
        self.color = color
    }
    
    public func makeBody(configuration: Configuration) -> some View {
		Group {
			if isLoading {
				ProgressView()
			} else {
				configuration.label
			}
			
		}
		.padding(.vertical, 8)
		.fixedSize()
        .animation(.linear(duration: 0.1), value: isLoading)
        .font(.montserratBold, 15)
        .foregroundStyle(foregroundColor)
        .opacity(isEnabled ? 1.0 : 0.5)
        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
        .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
