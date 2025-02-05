import SwiftUI

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
