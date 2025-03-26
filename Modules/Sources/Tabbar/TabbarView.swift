import EnterCode
import EventsFeature
import More
import DesignSystem
import SwiftUI
import ComposableArchitecture
import FeedbackFlow

public struct TabbarView: View {
    
    @Environment(\.scenePhase) private var scenePhase
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
        .onChange(of: scenePhase) {
            switch $0 {
            
            case .background:
                return
            case .inactive:
                return
            case .active:
                store.send(.didEnterForeground)
            @unknown default:
                return
            }
            
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
        .sheet(
            item: $store.scope(
                state: \.destination?.notificationPermissionPrompt,
                action: \.destination.notificationPermissionPrompt
            )
        ) { _ in
            NotificationPermissionView(
                requestAuthorizationButtonTap: {
                    store.send(.requestNotificationAuthorization)
                },
                dismissButtonTap: {
                    store.send(.dimissNotificationPermissionButtonTap)
                }
            )
            .presentationDetents([.height(600)])
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
