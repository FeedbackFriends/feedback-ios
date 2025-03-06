import DesignSystem
import ComposableArchitecture
import SwiftUI
import Helpers
import DesignSystem

public struct FeedbackFlowView: View {
    
    @Bindable var store: StoreOf<FeedbackFlow>
    
    public init(store: StoreOf<FeedbackFlow>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
                .buttonStyle(SecondaryToolbarButtonStyle())
                .foregroundStyle(Color.themeDarkGray)
                Spacer()
                Button {
                    store.send(.infoButtonTap)
                } label: {
                    Image(systemName: "info")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .padding(2)
                }
                .buttonStyle(IconToolbarStyle())
            }
            .overlay {
                Text(store.feedbackSession.title)
                    .font(.montserratBold, 16)
                    .foregroundColor(Color.themeDarkGray)
                    .lineLimit(1)
                    .padding(.horizontal, 60)
            }
            .padding(16)
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(Color.themeLightGray)
            ZStack {
                TabView(selection: $store.selectedFeedbackItemIndex.animation()) {
                    ForEach(store.scope(state: \.feedbackItems, action: \.feedbackItems), id: \.index) { store in
                        store.withState { feedbackItem in
                            /// Workaround to fix SwiftUI bug where animation is not visible if index is changed programmatically
                            ZStack {
                                FeedbackItemView(store: store)
                                    .tag(feedbackItem.index)
                            }
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .animation(.easeInOut(duration: 1.0), value: store.selectedFeedbackItemIndex) // 2
        .background(Color.themeBackground)
        .successOverlay(
            message: "Thanks for the feedback",
            show: $store.presentSuccessOverlay,
            enableAutomaticDismissal: false
        )
        .sheet(
            item: $store.scope(state: \.destination?.showMeetingInfo, action: \.destination.showMeetingInfo),
            content: { _ in
                EventInfoView(
                    eventTitle: store.feedbackSession.title,
                    eventAgenda: store.feedbackSession.agenda,
                    ownerName: store.feedbackSession.ownerInfo.name,
                    ownerEmail: store.feedbackSession.ownerInfo.email,
                    ownerphoneNumber: store.feedbackSession.ownerInfo.phoneNumber,
                    date: store.feedbackSession.date
                )
                .presentationDetents([.medium, .large])
            }
        )
        .statusBar(hidden: true)
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}
