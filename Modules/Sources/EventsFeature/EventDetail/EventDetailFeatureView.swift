import Helpers
import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct EventDetailFeatureView: View {
    
    @Bindable var store: StoreOf<EventDetailFeature>
    
    public init(store: StoreOf<EventDetailFeature>) {
        self.store = store
    }
    
    public var body: some View {
        
        let confirmationStore = $store.scope(
            state: \.destination?.confirmationDialog,
            action: \.destination.confirmationDialog
        )
        
        let inviteStore = $store.scope(
            state: \.destination?.invite,
            action: \.destination.invite
        )
                
        let editEventStore = $store.scope(
            state: \.destination?.editEvent,
            action: \.destination.editEvent
        )
        
        let deleteConfirmationStore = $store.scope(
            state: \.destination?.deleteConfirmation,
            action: \.destination.deleteConfirmation
        )
        
        DetailSectionView(
            event: store.event
        )
        .sheet(
            item: inviteStore
        ) { state in
            state.withState { event in
                InviteView(
                    code: event.pinCode,
                    inviteLink: store.inviteLink,
                    shareText: store.shareText
                ).presentationDetents([.height(350)])
            }
        }
        .confirmationDialog(confirmationStore)
        .refreshable {
            await store.send(.refresh).finish()
        }
        .foregroundColor(Color.themeDarkGray)
        .frame(maxWidth: .infinity)
        .task { store.send(.onAppear) }
        .toolbar { toolbarContent }
        .navigationTitle(store.navigationTitle)
        .sheet(
            item: editEventStore
        ) { store in
            NavigationStack {
                EditEventView(
                    store: store
                )
            }
        }
        .sheet(item: deleteConfirmationStore) { store in
            DeleteConfirmationView(store: store)
                .presentationDetents([.height(300)])
        }
    }
}

private extension EventDetailFeatureView {
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.send(.moreButtonTapped)
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(IconToolbarStyle())
            }
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailFeatureView(
            store: .init(
                initialState: .init(event: .mock(), session: .init(value: .mock())),
                reducer: {
                    EventDetailFeature()
                }
            )
        )
    }
}
