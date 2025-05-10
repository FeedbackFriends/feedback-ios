import SwiftUI

public struct SecondaryToolbarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.isLoading) private var isLoading: Bool
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
            } else {
                configuration.label
            }
        }
        .font(.montserratMedium, 15)
        .foregroundStyle(Color.themeDarkGray)
        .opacity(isEnabled ? 1.0 : 0.5)
        .animation(.default, value: isEnabled)
        .progressViewStyle(CircularProgressViewStyle(tint: Color.gray.opacity(0.5)))
        .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}
