import SwiftUI

@MainActor
public func listElementView(
    image: String,
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
        Image(systemName: image)
            .font(.system(size: 12, weight: .medium))
            .aspectRatio(contentMode: .fill)
            .padding(6)
            .foregroundStyle(Color.themeText)
        Text(label)
    }
    .font(.montserratRegular, 13)
    .animation(.bouncy, value: isLoading)
}
