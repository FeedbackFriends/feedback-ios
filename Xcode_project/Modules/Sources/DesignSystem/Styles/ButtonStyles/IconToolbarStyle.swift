import SwiftUI

public struct IconToolbarStyle: ButtonStyle {
    
    public init () {}
    
    let background: Color = Color.themeWhite
    @Environment(\.isEnabled) var isEnabled
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(8)
            .foregroundColor(Color.themeDarkGray)
            .background(isEnabled ? background : Color.themeHighligted)
            .cornerRadius(16)
            .lightShadow()
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}
