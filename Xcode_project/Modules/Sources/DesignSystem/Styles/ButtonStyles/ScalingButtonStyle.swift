import SwiftUI

public struct ScalingButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration
            .label
            .scaleEffect(configuration.isPressed ? 0.90 : 1)
            .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}
