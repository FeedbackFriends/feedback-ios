import AppCore
import SwiftUI

@main
struct FeedbackMockApp: App {
    var body: some Scene {
        WindowGroup {
            AppCoreView(
                store: .init(
                    initialState: AppCore.State(),
                    reducer: {
                        AppCore()._printChanges()
                    },
                    withDependencies: {
                        $0.apiClient = .mock()
                        $0.authClient = .mock
                    }
                )
            )
        }
    }
}
