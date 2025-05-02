import Helpers
import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct AccountSectionView: View {
    @Bindable var store: StoreOf<AccountSection>
    public init(store: StoreOf<AccountSection>) {
        self.store = store
    }
    
    public var body: some View {
        profileSection(
            name: store.accountInfo.name,
            email: store.accountInfo.email,
            phoneNumber: store.accountInfo.phoneNumber
        )
        if let role = store.session.role {
            accountTypeSection(role: role)
        }
    }
}

private extension AccountSectionView {
    func profileSection(
        name: String?,
        email: String?,
        phoneNumber: String?
    ) -> some View {
        Section {
            Button {
                store.send(.updateProfileButtonTap)
            } label: {
                VStack(alignment: .leading) {
                    Text(name ?? "Not found")
                        .font(.montserratRegular, 16)
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(.systemGray2))
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(email ?? "Not found")
                            Text(phoneNumber ?? "Not found")
                        }
                        .font(.montserratMedium, 10)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .padding(10)
                            .foregroundColor(Color(.systemGray2))
                    }
                }
                .foregroundColor(Color.themeDarkGray)
            }
        }
    }
    
    @ViewBuilder
    func accountTypeSection(
        role: Role
    ) -> some View {
        Section {
            Button {
                store.send(.changeUserTypeButtonTap)
            } label: {
                HStack {
                    Image.handshake
                        .resizable()
                        .renderingMode(.template)
                        .imageScale(.small)
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .padding(6)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                        .foregroundStyle(Color(.systemGray))
                    Text(role.localized)
                    Spacer()
                    Text("Edit")
                        .font(.montserratBold, 13)
                        .foregroundColor(.themePrimaryAction)
                }
                .font(.montserratRegular, 13)
                .foregroundColor(.themeDarkGray)
            }
        } header: {
            Text("Account type")
                .sectionHeaderStyle()
        }
    }
}

private struct SimpleCardSection: View {
    let header: String
    let content: String
    
    var body: some View {
        VStack {
            Text(header)
                .sectionHeaderStyle()
            Text(content)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.themeWhite)
                .cornerRadius(14)
                .font(.montserratRegular, 13)
        }
    }
}

#Preview {
    List {
        AccountSectionView(
            store: .init(
                initialState: .init(session: .init(value: .mock())),
                reducer: {
                    AccountSection()
                }
            )
        )
    }
}
