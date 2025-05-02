import SwiftUI
import Foundation
import Model

public struct ErrorView: View {
    
    let error: PresentableError
    let tryAgainButtonTapped: (() -> Void)?
    @Binding var isLoading: Bool
    @State var viewDidLoad: Bool = false
    
    var exclamationmark: CGFloat {
        if viewDidLoad {
            return 40.0
        } else {
            return 35.0
        }
    }
    
    public init(
        error: PresentableError,
        isLoading: Binding<Bool>,
        tryAgainButtonTapped: (() -> Void)? = nil
    ) {
        self.error = error
        self._isLoading = isLoading
        self.tryAgainButtonTapped = tryAgainButtonTapped
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "exclamationmark.circle.fill")
                .resizable()
                .frame(width: exclamationmark, height: exclamationmark)
                .foregroundColor(.themeRed)
            Text("\(error.title) 💩")
                .font(.montserratBold, 16)
                .foregroundColor(.themeDarkGray)
            Text(error.message)
                .font(.montserratRegular, 13)
                .foregroundColor(.themeDarkGray)
                .multilineTextAlignment(.center)
            if tryAgainButtonTapped != nil {
                Button {
                    self.tryAgainButtonTapped!()
                } label: {
                    Text("Try again")
                }
                .buttonStyle(PrimaryToolbarButtonStyle())
                .isLoading(isLoading)
                .disabled(isLoading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation {
                self.viewDidLoad = true
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        .padding(.horizontal, 50)
    }
}
