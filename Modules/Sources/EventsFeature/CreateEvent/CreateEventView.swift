import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct CreateEventView: View {
    
    @Bindable var store: StoreOf<CreateEvent>
    
    public init(store: StoreOf<CreateEvent>) {
        self.store = store
    }
    
    public var body: some View {
        Form {
            EventForm(
                eventInput: $store.eventInput,
                shouldOpenKeyboardOnAppear: true,
                recentlyUsedQuestions: store.recentlyUsedQuestions
            )
            .listRowBackground(Color.themeWhite)
        }
        .toolbar { toolbarItems }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitle("New meeting")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground.ignoresSafeArea())
        .animation(.default, value: store.eventInput.durationInMinutes)
        .alert($store.scope(state: \.alert, action: \.alert))
        .successOverlay(
            message: "Event created",
            show: $store.showSuccessOverlay,
            enableAutomaticDismissal: false
        )
    }
}

private extension CreateEventView {
    
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") {
                    store.send(.createEventButtonTap)
                }
                .buttonStyle(PrimaryToolbarButtonStyle())
                .isLoading(store.createEventRequestInFlight)
                .disabled(store.createEventButtonDisabled)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                SharedCloseButton {
                    store.send(.cancelButtonTap)
                }
                .buttonStyle(SecondaryToolbarButtonStyle())
            }
        }
    }
}
