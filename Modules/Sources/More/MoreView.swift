import Foundation
import SwiftUI
import DesignSystem
import ComposableArchitecture
import Helpers
import Helpers

public struct MoreView: View {
    
    @Bindable var store: StoreOf<More>
    
    public init(store: StoreOf<More>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            switch store.session.userType {
            case .anonymoous:
                EmptyView()
            case .participant(let accountData):
                profileSection(
                    name: accountData.name,
                    email: accountData.email,
                    phoneNumber: accountData.phoneNumber
                )
                accountTypeSection(role: Role.participant)
            case .manager(_, let accountData):
                profileSection(
                    name: accountData.name,
                    email: accountData.email,
                    phoneNumber: accountData.phoneNumber
                )
                accountTypeSection(role: Role.manager)
            }
            generalSection
            contactSection
            shareSection
            switch store.session.userType {
            case .anonymoous:
                signUpSection
            case .participant:
                logoutSection()
            case .manager:
                logoutSection()
                
            }
        }
        .font(.montserratRegular, 12)
        .toolbarBackground(
            Color.themeBackground,
            for: .tabBar
        )
        .listRowBackground(Color.themePrimaryAction)
        .foregroundColor(Color.themeDarkGray)
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .confirmationDialog(
            $store.scope(
                state: \.destination?.confirmationDialog,
                action: \.destination.confirmationDialog
            )
        )
        .sheet(
            item: $store.scope(
                state: \.destination?.changeUserType,
                action: \.destination.changeUserType
            )
        ) { store in
            ChangeUserTypeView(store: store)
                .presentationDetents([.height(240)])
        }
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.modifyAccount,
                action: \.destination.modifyAccount
            )
        ) { store in
            ModifyAccountView(store: store)
        }
    }
}

private extension MoreView {
    
    @ViewBuilder
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
                        .foregroundColor(Color(.systemGray))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .padding(10)
                            .foregroundColor(Color(.systemGray2))
                    }
                }
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
        }
        header: {
            Text("Account type")
                .sectionHeaderStyle()
        }
    }
    
    func logoutSection() -> some View {
        Section {
            
            Button {
                store.send(.signOutButtonTapped)
            } label: {
                listElement(image: "rectangle.portrait.and.arrow.right", label: "Logout")
            }
        } footer: {
            Text("\(store.appVersion)")
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .font(.montserratThin, 12)
                .padding(.vertical, 20)
        }
    }
    var signUpSection: some View {
        Section {
            Button {
                store.send(.signUpButtonTap)
            } label: {
                listElement(image: "person.badge.key", label: "Sign up")
            }
        } footer: {
            Text("Sign up to get feedback from others and much more")
        }
    }
    
    var generalSection: some View {
        Group {
            Section {
                Button {
                    store.send(.onNotificationsButtonTap)
                } label: {
                    listElement(image: "bell", label: "Notifications")
                }
                
                NavigationLink {
                    WebView(url: store.privacyPolicyUrl)
                        .edgesIgnoringSafeArea(.all)
                        .navigationTitle("Privacy policy")
                } label: {
                    listElement(image: "doc.plaintext", label: "Privacy policy")
                }
                Button {
                    store.send(.onSupportUsButtonTap)
                } label: {
                    HStack {
                        Image(systemName: "heart.fill")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.themePrimaryAction.gradient)
                        Text("Support us")
                    }
                    .font(.montserratRegular, 14)
                    .foregroundColor(.themeDarkGray)
                }
                
            } header: {
                Text("General")
                    .sectionHeaderStyle()
            }
        }
    }
    
    var contactSection: some View {
        Section {
            Button {
                store.send(.onFeedbackButtonTap)
            } label: {
                listElement(image: "ellipsis.bubble", label: "Send us feedback")
            }
            Button {
                store.send(.onReportBugButtonTap)
            } label: {
                listElement(image: "exclamationmark.square", label: "Report a bug")
            }
        } header: {
            Text("Contact us")
                .sectionHeaderStyle()
        }
    }
    
    var shareSection: some View {
        Section {
            ShareLink(item: store.appStoreReviewUrl) {
                VStack(spacing: 10) {
                    Text("Invite your colleagues")
                        .font(.montserratExtraBold, 18)
                    Text("Improve the feedback culture in the office 🤟🏽")
                        .font(.montserratMedium, 14)
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeWhite)
            }
        }
        .listRowBackground(
            Rectangle()
                .foregroundStyle(Color.themePrimaryAction.gradient)
        )
    }
}

#Preview("Manager") {
    NavigationStack {
        MoreView(
            store: StoreOf<More>(
                initialState: More.State(session: .init(value: .mock())),
                reducer: {
                    More()
                }
            )
        )
    }
}

#Preview("Participant") {
    NavigationStack {
        MoreView(
            store: StoreOf<More>(
                initialState: More.State(session: .init(value: .mockParticipant())),
                reducer: {
                    More()
                }
            )
        )
    }
}


#Preview("Anonymous") {
    NavigationStack {
        MoreView(
            store: StoreOf<More>(
                initialState: More.State(session: .init(value: .mockAnonymous())),
                reducer: {
                    More()
                }
            )
        )
    }
}

public func listElement(
    image: String,
    label: String,
    foregroundColor: Color = Color.themeDarkGray
) -> some View {
    HStack {
        Image(systemName: image)
            .font(.system(size: 12, weight: .medium))
            .aspectRatio(contentMode: .fill)
            .padding(6)
//            .background(Color(.systemGray5))
//            .clipShape(Circle())
            .foregroundStyle(Color.themeDarkGray)
        Text(label)
    }
    .font(.montserratRegular, 13)
    
}
