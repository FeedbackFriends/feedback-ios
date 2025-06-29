import SwiftUI

public extension View {
    func sfIconStyle(
        size: CGFloat = 14,
        weight: Font.Weight = .semibold,
        padding: CGFloat = 6,
        backgroundColor: Color = Color(.systemGray5),
        foregroundColor: Color = Color(.systemGray)
    ) -> some View {
        self.modifier(
            SFIconModifier(
                size: size,
                weight: weight,
                padding: padding,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor
            )
        )
    }
}

struct SFIconModifier: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight
    var padding: CGFloat
    var backgroundColor: Color
    var foregroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .fontWeight(.medium)
            .frame(width: size, height: size, alignment: .center)
            .foregroundColor(.themeDarkGray.opacity(0.6))
            .padding(8)
            .background(Color.themeWhite, in: Capsule())
            .lightShadow()
    }
}
