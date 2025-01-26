import FeedbackFlow
import ComposableArchitecture
import SwiftUI
import APIClient
import FirebaseAuth
import DependencyClients

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
