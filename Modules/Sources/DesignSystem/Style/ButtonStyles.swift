import SwiftUI

public struct OpacityButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(.none, value: configuration.isPressed)
    }
}

public struct LargeBoxButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    let isLoading: Bool
    let color: Color
    let style: Style
    
    public enum Style {
        case primary, secondary
    }
    
    public init(isLoading: Bool = false, color: Color = Color.themeDarkGray, style: Style = .primary) {
        self.isLoading = isLoading
        self.color = color
        self.style = style
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        switch style {
        case .primary:
            bodyView(configuration)
                .font(.montserratSemiBold, 16)
        case .secondary:
            bodyView(configuration)
                .font(.montserratRegular, 16)
        }
    }
    
    func bodyView(_ configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .transition(.blurReplace)
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
                
            }
            configuration.label
        }
        .animation(.default, value: isLoading)
        .padding(.leading, 12)
        .frame(maxWidth: .infinity, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .leading)
        .background(Color.themeWhite)
        .cornerRadius(Theme.cornerRadius)
        .foregroundColor(color)
        .opacity(configuration.isPressed ? 0.4 : 1)
    }
}


public struct LargeButtonStyle<Input: ShapeStyle>: ButtonStyle {

    @Environment(\.isLoading) private var isLoading
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.dismiss) private var dismiss
    
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
            }
            configuration.label
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

extension EnvironmentValues {
    @Entry var isLoading: Bool = false
}

public extension View {
  func isLoading(_ isLoading: Bool) -> some View {
      environment(\.isLoading, isLoading)
  }
}
