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
        moreContent
            .task { store.send(.task) }
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
    }
}

private extension MoreView {
    
    private var moreContent: some View {
        List {
            switch store.session.userType {
            case .anonymoous:
                EmptyView()
            case .participant(let accountData):
                profileSection(
                    name: accountData.name ?? "-",
                    email: accountData.email ?? "-",
                    phoneNumber: accountData.phoneNumber
                )
            case .manager(_, let accountData):
                profileSection(
                    name: accountData.name ?? "-",
                    email: accountData.email ?? "-",
                    phoneNumber: accountData.phoneNumber
                )
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
            #if !RELEASE
            developerSection
            #endif
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
    }
    
    @ViewBuilder
    func profileSection(name: String, email: String, phoneNumber: String?) -> some View {
        
        Section {
            listElement(image: "person.fill", label: name)
            listElement(image: "envelope.fill", label: email)
            if let phoneNumber {
                listElement(image: "envelope.fill", label: phoneNumber)
            }

            } header: {
                Text("Profile")
                    .sectionHeaderStyle()
            }
    }
    
    func logoutSection() -> some View {
        Section {

            Button {
                store.send(.signOutButtonTapped)
            } label: {
                listElement(image: "rectangle.portrait.and.arrow.right.fill", label: "Logout")
            }
        } footer: {
            Text("Version \(store.appVersion)")
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
                listElement(image: "rectangle.portrait.fill", label: "Sign up")
            }
        } footer: {
            Text("Sign up to create an account and continue your journey as a feedback participant or to receive feedback from others.")
        }
    }
    
    var developerSection: some View {
        NavigationLink("Developer Menu") {
            ScrollView {
                Text("Firebase ID Token for logged in user (Hold to copy)")
                    .font(.callout)
                    .padding(.bottom, 16)
                Text(store.idToken ?? "No firebase token")
                    .textSelection(.enabled)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .foregroundStyle(Color.black)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Developer Menu")
            }
        }
    }
    
    var generalSection: some View {
        Group {
            Section {
//                                NavigationLink {
//                                    ScrollView {
//                                        ColorSchemePicker(colorScheme: $settings.colorScheme)
//                                        .toggleStyle(SwitchToggleStyle(tint: .orange))
//                                    }
//                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                                } label: {
//                                    listElement(image: "lightbulb.led.fill", label: "Appearance")
//                                }
                Button {
                    store.send(.onNotificationsButtonTap)
                } label: {
                    listElement(image: "bell.circle.fill", label: "Notifications")
                }
                
                NavigationLink {
                    ScrollView {
                        Text(store.string)
                            .navigationTitle("Terms of service")
                            .navigationBarTitleDisplayMode(.inline)
                            .padding()
                            .multilineTextAlignment(.leading)
                            
                    }
                } label: {
                    listElement(image: "book.closed.fill", label: "Terms of Service")
                }
                NavigationLink {
                    ScrollView {
                        Text(store.string)
                            .navigationTitle("Privacy policy")
                            .navigationBarTitleDisplayMode(.inline)
                            .padding()
                            .multilineTextAlignment(.leading)
                    }
                } label: {
                    listElement(image: "doc.plaintext.fill", label: "Privacy policy")
                }
                NavigationLink {
                    ScrollView {
                        Text(store.string)
                            .navigationTitle("License")
                            .navigationBarTitleDisplayMode(.inline)
                            .padding()
                            .multilineTextAlignment(.leading)
                    }
                } label: {
                    listElement(image: "character.book.closed.fill", label: "License")
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
//            Picker(selection: $store.userType.unwrapped()) {
//                ForEach(Role.allCases, id: \.self) {
//                    Text($0.localization)
//                }
//            } label: {
//                Text("User mode")
//                    .sectionHeaderStyle()
//            }
        }
    }
    
    var contactSection: some View {
        Section {
            Button {
                store.send(.onFeedbackButtonTap)
            } label: {
                listElement(image: "ellipsis.bubble.fill", label: "Send us feedback")
            }
            Button {
                store.send(.onReportBugButtonTap)
            } label: {
                listElement(image: "exclamationmark.square.fill", label: "Report a bug")
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
