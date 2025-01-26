import EnterCode
import EventsFeature
import More
import DesignSystem
import FirebaseAuth
import SwiftUI
import ComposableArchitecture
import FeedbackFlow

public struct TabbarView: View {
    
    @State var debugMenuVisible: Bool = false
    
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
                Image(systemName: "hand.")
                Text("Feedback")
            }
            .tag(Tab.feedback)
            NavigationStack {
                EventsOverviewView(store: store.scope(state: \.eventsOverview, action: \.eventsOverview))
                    .navigationTitle("Events")
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Meetings")
            }
            .tag(Tab.events)
            NavigationStack {
                MoreView(store: store.scope(state: \.more, action: \.more))
                    .navigationTitle("More")
            }
            .tabItem {
                Image(systemName: "ellipsis")
                Text("More")
            }
            .tag(Tab.more)
        }
        .overlay(alignment: .trailing) {
            HStack {
                Button {
                    withAnimation {
                        self.debugMenuVisible.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.compact.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding()
                }
                if debugMenuVisible {
                    VStack {
                        Button("Print session") {
                            store.send(.printSession)
                        }
                        Button("Print id token") {
                            Task {
                                let token = try await Auth.auth().currentUser?.getIDToken()
                                print(token ?? "Token not found")
                            }
                        }
                        Button("Crash") {
                            fatalError("Debug crash")
                        }
                    }
                    .padding()
                }
            }
            .background(Color.blue)
            .foregroundStyle(Color.white)
        }
        .alert($store.scope(state: \.initialiseFeedback.destination?.alert, action: \.initialiseFeedback.destination.alert))
        .sheet(item: $store.scope(state: \.initialiseFeedback.destination?.ratingPrompt, action: \.initialiseFeedback.destination.ratingPrompt)) { _ in
            RatingAlertView()
                .presentationDetents([.height(300)])
        }
        .fullScreenCover(item: $store.scope(state: \.initialiseFeedback.destination?.feedbackFeature, action: \.initialiseFeedback.destination.feedbackFeature)) { store in
            FeedbackFlowView(store: store)
        }
        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
        .onAppear { store.send(.onAppear) }
    }
}
