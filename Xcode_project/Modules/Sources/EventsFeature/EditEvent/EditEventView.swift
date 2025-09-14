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
        EventFormView(
            eventInput: $store.eventInput,
            shouldOpenKeyboardOnAppear: false,
            recentlyUsedQuestions: store.recentlyUsedQuestions,
            successOverlayMessage: "Event edited",
            showSuccessOverlay: $store.showSuccessOverlay,
            action: {
                Button("Save") {
                    store.send(.editEventButtonTap)
                }
                .buttonStyle(PrimaryTextButtonStyle())
                .isLoading(store.editRequestInFlight)
                .disabled(store.editEventButtonDisabled)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .disabled(store.showSuccessOverlay)
        .animation(.default, value: store.eventInput)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
