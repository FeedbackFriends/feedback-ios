import SwiftUI
import DesignSystem
import Model

@main
struct FeedbackErrorApp: App {
    var body: some Scene {
        WindowGroup {
            ErrorViewWrapper()
        }
    }
}

struct ErrorViewWrapper: View {
    @State var isLoading = false
    var body: some View {
        ErrorView(
            error: PresentableError(
                title: "Title",
                message: "Message"
            ),
            isLoading: $isLoading,
            tryAgainButtonTapped: {
                
            }
        )
    }
}
