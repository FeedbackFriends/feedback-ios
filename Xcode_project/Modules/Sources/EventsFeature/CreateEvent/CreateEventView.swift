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
        Form {
            EventForm(
                eventInput: $store.eventInput,
                shouldOpenKeyboardOnAppear: true,
                recentlyUsedQuestions: store.recentlyUsedQuestions
            )
            .listRowBackground(Color.themeSurface)
        }
        .toolbar { toolbarItems }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitle("New event")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
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
            ToolbarItem(placement: .primaryAction) {
				Button("Create") {
					store.send(.createEventButtonTap)
				}
				.buttonStyle(PrimaryTextButtonStyle())
                .isLoading(store.createEventRequestInFlight)
                .disabled(store.createEventButtonDisabled)
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

#Preview {
	NavigationStack {
		CreateEventView(
			store: StoreOf<CreateEvent>(initialState: .init(recentlyUsedQuestions: Set<RecentlyUsedQuestions>([]))) {
				CreateEvent()
			}
		)
	}
}
