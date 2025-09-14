import ComposableArchitecture
import DesignSystem
import SwiftUI
import Model

public struct CreateEventView: View {
    
    @Bindable var store: StoreOf<CreateEvent>
    
    public init(store: StoreOf<CreateEvent>) {
        self.store = store
    }
    
    public var body: some View {
        EventFormView(
            eventInput: $store.eventInput,
            shouldOpenKeyboardOnAppear: true,
            recentlyUsedQuestions: store.recentlyUsedQuestions,
            successOverlayMessage: "Event created",
            showSuccessOverlay: $store.showSuccessOverlay,
            action: {
                Button("Create") {
                    store.send(.createEventButtonTap)
                }
                .buttonStyle(PrimaryTextButtonStyle())
                .isLoading(store.createEventRequestInFlight)
                .disabled(store.createEventButtonDisabled)
            }
        )
        .navigationBarTitle("New event")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .animation(.default, value: store.eventInput.durationInMinutes)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    NavigationStack {
        CreateEventView(
            store: StoreOf<CreateEvent>(
                initialState: .init(recentlyUsedQuestions: Set<RecentlyUsedQuestions>([]))
            ) {
                CreateEvent()
            }
        )
    }
}
