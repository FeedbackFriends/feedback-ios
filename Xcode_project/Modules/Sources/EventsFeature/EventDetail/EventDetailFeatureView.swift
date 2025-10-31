import Domain
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
                let inviteLink = store.inviteUrl
                return InviteView(
                    code: event.pinCode?.value ?? "",
                    inviteLink: inviteLink,
                    shareText: event.shareText(inviteLink: inviteLink)
                )
                .presentationDetents([.height(350)])
            }
        }
        .refreshable {
            await store.send(.refresh).finish()
        }
        .foregroundColor(Color.themeText)
        .frame(maxWidth: .infinity)
        .task { await store.send(.onTask).finish() }
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("More", systemImage: "ellipsis") {
					store.send(.moreButtonTapped)
				}
				.tint(Color.themeText)
				.confirmationDialog(confirmationStore)
			}
		}
        .navigationTitle(store.navigationTitle)
        .navigationSubtitle(store.navigationSubTitle)
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
        .animation(.default, value: store.event)
    }
}


extension ManagerEvent {
    func shareText(inviteLink: String?) -> String {
    """
    You’re invited to \(self.title)!   
    Use pin code \(self.pinCode?.value ?? "[Not Found]") to join.
    
    👇🏼 Tap the link to join:  
    \(inviteLink ?? "[Not Found]")
    """
    }
}
