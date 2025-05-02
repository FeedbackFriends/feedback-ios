import SwiftUI
import DesignSystem
import ComposableArchitecture

struct DeleteConfirmationView: View {
    @Bindable var store: StoreOf<DeleteConfirmation>
    
    public init(store: StoreOf<DeleteConfirmation>) {
        self.store = store
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Are you sure you want to delete the event?")
                            .font(.montserratRegular, 14)
                    }
                    VStack(alignment: .center, spacing: 12) {
                        
                        Button("Delete") {
                            store.send(.deleteButtonTap)
                        }
                        .buttonStyle(LargeBoxButtonStyle(color: Color.themeRed))
                        .isLoading(store.deleteEventInFlight)
                        
                        Button("Cancel") {
                            store.send(.cancelButtonTap)
                        }
                        .buttonStyle(LargeBoxButtonStyle(style: .secondary))
                    }
                }
                .padding(.horizontal, 18)
                .navigationTitle("Delete")
                .navigationBarTitleDisplayMode(.large)
                .foregroundStyle(Color.themeDarkGray)
                .background(Color.themeBackground.ignoresSafeArea())
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SharedCloseButton {
                        store.send(.cancelButtonTap)
                    }
                }
            }
        }
        .successOverlay(
            message: "Event deleted",
            show: $store.showSuccessOverlay
        )
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}
#Preview {
    DeleteConfirmationView(
        store: .init(
            initialState: .init(session: .init(value: .mock()), eventId: UUID()),
            reducer: { DeleteConfirmation()
            }
        )
    )
}

#Preview {
    @Previewable @State var showDeleteConfirmation: Bool = false
    Button("Delete") {
        showDeleteConfirmation = true
    }
    .sheet(isPresented: $showDeleteConfirmation) {
        DeleteConfirmationView(
            store: .init(
                initialState: .init(session: .init(value: .mock()), eventId: UUID()),
                reducer: {
                    DeleteConfirmation()
                }
            )
        )
    }
}
