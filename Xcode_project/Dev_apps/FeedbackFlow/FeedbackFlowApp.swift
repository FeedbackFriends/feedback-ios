import ComposableArchitecture
import SwiftUI
import FeedbackFlowFeature

@main
struct FeedbackFlowApp: App {
    var body: some Scene {
        WindowGroup {
            FeedbackFlowView(
                store: StoreOf<FeedbackFlow>(
                    initialState: FeedbackFlow.State(
                        feedbackSession: .mock
                    ),
                    reducer: {
                        FeedbackFlow()._printChanges()
                    },
                    withDependencies: {
                        $0.apiClient = .mock()
                    }
                )
            )
        }
    }
}
