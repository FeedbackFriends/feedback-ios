import SwiftUI

public struct SecondaryToolbarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.montserratMedium, 15)
            .foregroundStyle(Color.themeDarkGray)
            .opacity(isEnabled ? 1.0 : 0.5)
            .animation(.default, value: isEnabled)
            .progressViewStyle(CircularProgressViewStyle(tint: Color.gray.opacity(0.5)))
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}
