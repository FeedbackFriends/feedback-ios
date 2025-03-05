import EnterCode
import EventsFeature
import More
import DesignSystem
import FirebaseAuth
import SwiftUI
import ComposableArchitecture
import FeedbackFlow

public struct TabbarView: View {
    
    @Bindable var store: StoreOf<Tabbar>
    
    public init(store: StoreOf<Tabbar>) {
        self.store = store
    }
    
    public var body: some View {
        tabbarView
    }
}
private extension TabbarView {
    
    var tabbarView: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                EnterCodeView(store: store.scope(state: \.enterCode, action: \.enterCode))
            }
            .tabItem {
                Image.handshake
                    .renderingMode(.template)
                    .imageScale(.small)
                Text("Feedback")
            }
            .tag(Tab.feedback)
            NavigationStack {
                EventsOverviewView(store: store.scope(state: \.eventsOverview, action: \.eventsOverview))
                    .navigationTitle("Events")
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Events")
            }
            .tag(Tab.events)
            NavigationStack {
                MoreView(store: store.scope(state: \.more, action: \.more))
                    .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
            .tag(Tab.more)
        }
        .alert($store.scope(state: \.initialiseFeedback.destination?.alert, action: \.initialiseFeedback.destination.alert))
        .sheet(
            item: $store.scope(
                state: \.initialiseFeedback.destination?.ratingPrompt,
                action: \.initialiseFeedback.destination.ratingPrompt
            )
        ) { _ in
            RatingAlertView()
                .presentationDetents([.height(300)])
        }
        .fullScreenCover(
            item: $store.scope(
                state: \.initialiseFeedback.destination?.feedbackFeature,
                action: \.initialiseFeedback.destination.feedbackFeature
            )
        ) { store in
            FeedbackFlowView(store: store)
        }
        .onAppear { store.send(.onAppear) }
    }
}
