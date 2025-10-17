import SwiftUI

public struct SharedCloseButtonView: View {
        
    var closeButtonTapped: () -> Void
    
    public init(_ closeButtonTapped: @escaping () -> Void) {
        self.closeButtonTapped = closeButtonTapped
    }
    
    public var body: some View {
        Button {
            closeButtonTapped()
        } label: {
            Image.xmark
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .padding(2)
				.foregroundStyle(Color.themeText)
        }
    }
}
