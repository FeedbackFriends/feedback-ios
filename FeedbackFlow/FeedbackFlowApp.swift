import FeedbackFlow
import ComposableArchitecture
import SwiftUI
import Helpers
import FirebaseAuth
import Helpers

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
                        FeedbackFlow()
                    },
                    withDependencies: {
                        $0.apiClient = .mock
                    }
                )
            )
        }
    }
}

extension SystemClient: @retroactive DependencyKey {
    public static var liveValue: SystemClient { .live }
}
