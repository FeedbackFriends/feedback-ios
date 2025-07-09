import Model
import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct AccountSectionView: View {
	
    @Bindable var store: StoreOf<AccountSection>
    public init(store: StoreOf<AccountSection>) {
        self.store = store
    }
    
    public var body: some View {
		AccountSectionContentView(
			data: .init(
				name: store.accountInfo.name,
				email: store.accountInfo.email,
				phoneNumber: store.accountInfo.phoneNumber,
				role: store.session.role,
				updateProfileButtonTap: {
					store.send(.updateProfileButtonTap)
				},
				changeUserTypeButtonTap: {
					store.send(.changeUserTypeButtonTap)
				}
			)
		)
    }
}
