import Foundation
import SwiftUI
import ComposableArchitecture
import DesignSystem
import Domain

public struct ChangeUserTypeView: View {
    
    @Bindable var store: StoreOf<ChangeUserType>
    
    public init(store: StoreOf<ChangeUserType>) {
        self.store = store
    }
    
    public var body: some View {
		NavigationStack {
			VStack(alignment: .leading, spacing: 12) {
				HStack {
					Text("Choose prefered user type")
						.font(.montserratSemiBold, 16)
						.foregroundColor(.themeText)
					Spacer()
				}
				.padding(.bottom, 8)
				VStack(alignment: .leading, spacing: 10) {
					UserTypePickerView(selectedUserType: $store.selectedUserType)
					Button {
						store.send(.saveButtonTap)
					} label: {
						Text("Save")
					}
					.buttonStyle(LargeButtonStyle())
					.isLoading(store.isLoading)
					.padding(.bottom, 16)
				}
			}
			.padding(.all, Theme.padding)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					CloseButtonView {
						store.send(.closeButtonTap)
					}
				}
				.sharedBackgroundVisibility(.hidden)
			}
		}
    }
}

#Preview {
    ChangeUserTypeView(
        store: .init(
            initialState: .init(selectedUserType: Role.manager),
            reducer: {
                ChangeUserType()
            }
        )
    )
}
