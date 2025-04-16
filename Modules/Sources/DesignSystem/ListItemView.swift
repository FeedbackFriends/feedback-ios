import SwiftUI

public func listElementView(
    image: String,
    label: String,
    foregroundColor: Color = Color.themeDarkGray
) -> some View {
    HStack {
        Image(systemName: image)
            .font(.system(size: 12, weight: .medium))
            .aspectRatio(contentMode: .fill)
            .padding(6)
            .foregroundStyle(Color.themeDarkGray)
        Text(label)
    }
    .font(.montserratRegular, 13)
    
}
