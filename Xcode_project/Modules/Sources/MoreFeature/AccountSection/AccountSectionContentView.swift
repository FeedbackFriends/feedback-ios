import ComposableArchitecture
import Domain
import SwiftUI
import DesignSystem

struct AccountSectionContentView: View {
	let data: AccountSectionContentViewData
	var body: some View {
		profileSection(
			name: data.name,
			email: data.email,
			phoneNumber: data.phoneNumber
		)
		if let role = data.role {
			accountTypeSection(role: role)
		}
	}
}

struct AccountSectionContentViewData {
	let name: String?
	let email: String?
	let phoneNumber: String?
	let role: Role?
	let updateProfileButtonTap: () -> Void
	let changeUserTypeButtonTap: () -> Void
}

private extension AccountSectionContentView {
    func profileSection(
        name: String?,
        email: String?,
        phoneNumber: String?
    ) -> some View {
        Section {
            Button {
				data.updateProfileButtonTap()
            } label: {
                VStack(alignment: .leading) {
                    Text(name ?? "Not found")
                        .font(.montserratRegular, 16)
                    HStack {
                        Image.personCircleFill
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
                        Image.chevronRight
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .padding(10)
                            .foregroundColor(Color(.systemGray2))
                    }
                }
                .foregroundColor(Color.themeText)
            }
        }
    }
    
    @ViewBuilder
    func accountTypeSection(
        role: Role
    ) -> some View {
        Section {
            Button {
				data.changeUserTypeButtonTap()
            } label: {
                HStack {
                    Image.letsGrowIcon
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
                .foregroundColor(.themeText)
            }
        } header: {
            Text("Account type")
                .sectionHeaderStyle()
        }
    }
}

#Preview("Profile data") {
	List {
		AccountSectionContentView(
			data: .init(
				name: "Name",
				email: "Email",
				phoneNumber: "Phone",
				role: .manager,
				updateProfileButtonTap: {},
				changeUserTypeButtonTap: {}
			)
		)
	}
}

#Preview("Empty profile") {
	List {
		AccountSectionContentView(
			data: .init(
				name: nil,
				email: nil,
				phoneNumber: nil,
				role: .manager,
				updateProfileButtonTap: {},
				changeUserTypeButtonTap: {}
			)
		)
	}
}
