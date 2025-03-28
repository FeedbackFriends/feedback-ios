import Foundation
import SwiftUI
import ComposableArchitecture
import DesignSystem
import Helpers

public struct ChangeUserTypeView: View {
    
    @Bindable var store: StoreOf<ChangeUserType>
    
    public init(store: StoreOf<ChangeUserType>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Choose prefered user type")
                    .font(.montserratBold, 14)
                    .foregroundColor(.themeDarkGray)
                Spacer()
                SharedCloseButton {
                    store.send(.closeButtonTap)
                }
            }
            .padding(.bottom, 10)
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
        .background(Color.themeBackground)
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

