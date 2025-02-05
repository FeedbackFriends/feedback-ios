import ComposableArchitecture
import SwiftUI
import Helpers
import DesignSystem

public struct ModifyAccountView: View {
    
    @Bindable var store: StoreOf<ModifyAccount>
    
    public init(store: StoreOf<ModifyAccount>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $store.nameInput)
                } header: {
                    Text("Name")
                }
                Section {
                    TextField("Email", text: $store.emailInput)
                } header: {
                    Text("Email")
                }
                Section {
                    TextField("Phone number", text: $store.phoneNumberInput)
                } header: {
                    Text("Phone number")
                }
            }
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .scrollContentBackground(.hidden)
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        store.send(.saveButtonTap)
                    }
                    .buttonStyle(PrimaryToolbarButtonStyle())
                    .isLoading(store.isLoading)
                }
            }
        }
    }
}
