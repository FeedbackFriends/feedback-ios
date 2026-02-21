import SwiftUI

@MainActor
public func listElementView(
    image: Image,
    label: String,
    foregroundColor: Color = Color.themeText,
    isLoading: Bool = false
) -> some View {
    HStack {
        if isLoading {
            ProgressView()
                .transition(.blurReplace)
                .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
            
        }
        image
            .font(.system(size: 12, weight: .medium))
            .aspectRatio(contentMode: .fill)
            .padding(6)
        Text(label)
    }
    .font(.montserratSemiBold, 13)
    .foregroundStyle(Color.themeText)
    .animation(.bouncy, value: isLoading)
}
