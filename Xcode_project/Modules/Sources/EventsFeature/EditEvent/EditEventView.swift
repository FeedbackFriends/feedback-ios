import ComposableArchitecture
import Model
import DesignSystem
import SwiftUI

public struct EditEventView: View {
    
    @Bindable var store: StoreOf<EditEvent>
    @Environment(\.dismiss) var dismiss
    
    public init(store: StoreOf<EditEvent>) {
        self.store = store
    }
    
    public var body: some View {
        Form {
            EventForm(
                eventInput: $store.eventInput,
                shouldOpenKeyboardOnAppear: false,
                recentlyUsedQuestions: store.recentlyUsedQuestions
            )
        }
        .toolbar { toolbarItems }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .disabled(store.showSuccessOverlay)
        .animation(.default, value: store.eventInput)
        .alert($store.scope(state: \.alert, action: \.alert))
        .successOverlay(
            message: "Event edited",
            show: $store.showSuccessOverlay
        )
    }
}

private extension EditEventView {
    
    var toolbarItems: some ToolbarContent {
        Group {
			ToolbarItem(placement: .primaryAction) {
				Button("Save") {
					store.send(.editEventButtonTap)
				}
				.buttonStyle(PrimaryTextButtonStyle())
				.isLoading(store.editRequestInFlight)
				.disabled(store.editEventButtonDisabled)
			}
			.sharedBackgroundVisibility(.hidden)
            ToolbarItem(placement: .cancellationAction) {
                SharedCloseButtonView {
                    store.send(.cancelButtonTap)
                }
                .buttonStyle(SecondaryTextButtonStyle())
            }
        }
    }
}
