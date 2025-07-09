import SwiftUI

public struct IconToolbarStyle: ButtonStyle {
    
    public init () {}
    
	let background: Color = Color.themeSurface
    @Environment(\.isEnabled) var isEnabled
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(8)
            .foregroundColor(Color.themeText)
			.background(isEnabled ? background : background.opacity(0.6))
            .clipShape(Circle())
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}
