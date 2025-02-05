import SwiftUI

public struct CoolToolbarIconStyling: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content
            .font(.body.weight(.bold))
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .foregroundColor(.themeDarkGray)
            .background(.ultraThinMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
    }
}


