import SwiftUI

public struct IconToolbarStyle: ButtonStyle {
    
    public init () {}
    
    let background: Color = Color.white
    @Environment(\.isEnabled) var isEnabled
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(8)
            .foregroundColor(Color.themeDarkGray)
            .background(isEnabled ? background : Color.themeHighligted)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 2)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}
