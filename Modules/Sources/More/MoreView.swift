import Foundation
import SwiftUI
import DesignSystem
import ComposableArchitecture
import Helpers
import APIClient

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
                accountTypeSection(claim: Claim.participant)
            case .manager(_, let accountData):
                profileSection(
                    name: accountData.name,
                    email: accountData.email,
                    phoneNumber: accountData.phoneNumber
                )
                accountTypeSection(claim: Claim.manager)
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
        .task { store.send(.task) }
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
                    Text(name ?? "Name not found")
                        .font(.montserratMedium, 18)
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(.systemGray2))
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 8) {
                            //                            HStack {
                            //                                Image(systemName: "envelope")
                            Text(email ?? "Email not found")
                            //                            }
                            //                            HStack {
                            //                                Image(systemName: "phone")
                            Text(phoneNumber ?? "Phone number not found")
                            //                            }
                        }
                        .font(.montserratMedium, 12)
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
        header: {
            Text("Profile")
                .sectionHeaderStyle()
        }
    }
    
    @ViewBuilder
    func accountTypeSection(
        claim: Claim
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
                    Text(claim.localized)
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
                    WebView(url: .init(string: "https://localhost:5173/privacy-policy")!)
                        .edgesIgnoringSafeArea(.all)
                        .navigationTitle("Privacy policy")
                } label: {
                    listElement(image: "doc.plaintext", label: "Privacy policy")
                }
                //                NavigationLink {
                //                    ScrollView {
                //                        Text(store.string)
                //                            .navigationTitle("License")
                //                            .navigationBarTitleDisplayMode(.inline)
                //                            .padding()
                //                            .multilineTextAlignment(.leading)
                //                    }
                //                } label: {
                //                    listElement(image: "character.book.closed.fill", label: "License")
                //                }
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
            ShareLink(item: store.url) {
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

struct SFIconModifier: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight
    var padding: CGFloat
    var backgroundColor: Color
    var foregroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight))
            .aspectRatio(contentMode: .fill)
            .padding(padding)
            .background(backgroundColor)
            .clipShape(Circle())
            .foregroundStyle(foregroundColor)
    }
}

// Extension for easy usage
extension View {
    func sfIconStyle(
        size: CGFloat = 12,
        weight: Font.Weight = .bold,
        padding: CGFloat = 6,
        backgroundColor: Color = Color(.systemGray5),
        foregroundColor: Color = Color(.systemGray)
    ) -> some View {
        self.modifier(SFIconModifier(size: size, weight: weight, padding: padding, backgroundColor: backgroundColor, foregroundColor: foregroundColor))
    }
}

public func listElement(
    image: String,
    label: String,
    foregroundColor: Color = Color.themeDarkGray
) -> some View {
    HStack {
        Image(systemName: image)
            .sfIconStyle()
        Text(label)
    }
    .font(.montserratRegular, 13)
    .foregroundColor(foregroundColor)
}
