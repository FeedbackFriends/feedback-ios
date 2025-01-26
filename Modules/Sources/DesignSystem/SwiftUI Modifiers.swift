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

public struct SharedCloseButton: View {
        
    var closeButtonTapped: () -> Void
    
    public init(_ closeButtonTapped: @escaping () -> Void) {
        self.closeButtonTapped = closeButtonTapped
    }
    
    public var body: some View {
        Button {
            closeButtonTapped()
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .fontWeight(.bold)
                .frame(width: 14, height: 14, alignment: .center)
                .foregroundColor(.themeDarkGray.opacity(0.6))
                .padding(8)
                .background(Color.white, in: Capsule())
//                .background(Material.regularMaterial, in: Capsule())
        }
    }
}


public struct CustomGroupBoxStyle: GroupBoxStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .background(Color.themeWhite)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}


