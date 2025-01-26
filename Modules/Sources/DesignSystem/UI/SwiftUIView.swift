import SwiftUI

#warning("Lav generisk så den tager i mod optional view i stedet for image string")
public func listElement(image: String, label: String) -> some View {
    HStack {
        Image(systemName: image)
            .frame(width: 24, height: 24)
        Text(label)
    }
    .font(.montserratRegular, 14)
    .foregroundColor(.themeDarkGray)
}

#Preview {
    listElement(image: "image", label: "label")
}
