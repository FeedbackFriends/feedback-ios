import SwiftUI
import StoreKit
import Model
import DesignSystem

public struct RatingAlertView: View {
    
    let title: String
    let message: String
    @Environment(\.dismiss) var dismiss
    @AccessibilityFocusState private var isFocused: Bool
    @Environment(\.requestReview) var requestReview
    
    public init(
        title: String = "Happy with the app so far?",
        message: String = "A rating on App Store can encourage others to give it a try. 👌🏽"
    ) {
        self.title = title
        self.message = message
    }
    
    public var body: some View {
        NavigationStack {
            content
                .presentationDetents([.height(300)])
                .frame(maxWidth: .infinity)
                .background(Color.themeBackground.ignoresSafeArea())
                .interactiveDismissDisabled()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        SharedCloseButtonView {
                            self.dismiss()
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button {
                                self.dismiss()
                            } label: {
                                Text("Not now")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondaryToolbarButtonStyle())
                            Spacer()
                            Button {
                                Task { @MainActor in
                                    self.dismiss()
                                    // Delay the task by 0.5 second
                                    try await Task.sleep(for: .seconds(0.5))
                                    requestReview()
                                }
                            } label: {
                                Text("Rate app")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryToolbarButtonStyle())
                        }
                    }
                }
        }
        .background(Color.themeBackground.ignoresSafeArea())
    }
}

private extension RatingAlertView {
    
    private var content: some View {
        VStack(alignment: .center, spacing: 26) {
            Text(title)
                .font(.montserratBold, 20)
                .foregroundColor(Color.themeDarkGray)
                .multilineTextAlignment(.center)
                .accessibilityFocused($isFocused)
            LottieView(lottieFile: .fiveStars)
                .frame(width: 300, height: 36)
            Text(message)
                .font(.montserratRegular, 14)
                .foregroundColor(Color.themeDarkGray.opacity(0.7))
                .multilineTextAlignment(.center)
                .accessibilityFocused($isFocused)
                .lineSpacing(5)
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}
