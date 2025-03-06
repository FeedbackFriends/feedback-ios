import SwiftUI

public struct LargeBoxButtonStyle: ButtonStyle {
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
    }
}
