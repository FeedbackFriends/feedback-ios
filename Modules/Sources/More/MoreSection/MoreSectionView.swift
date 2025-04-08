import Foundation
import SwiftUI
import DesignSystem
import ComposableArchitecture
import Helpers

public struct MoreSectionView: View {
    
    @Bindable var store: StoreOf<MoreSection>
    
    public init(store: StoreOf<MoreSection>) {
        self.store = store
    }
    
    public var body: some View {
         Group {
            generalSection
            contactSection
            shareSection
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
        .foregroundColor(Color.themeDarkGray)
        .scrollContentBackground(.hidden)
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
    
#warning("Fix me")
    //#Preview("Manager") {
    //    NavigationStack {
    //        MoreView(
    //            store: StoreOf<More>(
    //                initialState: More.State(session: .init(value: .mock())),
    //                reducer: {
    //                    More()
    //                }
    //            )
    //        )
    //    }
    //}
    //
    //#Preview("Participant") {
    //    NavigationStack {
    //        MoreView(
    //            store: StoreOf<More>(
    //                initialState: More.State(session: .init(value: .mockParticipant())),
    //                reducer: {
    //                    More()
    //                }
    //            )
    //        )
    //    }
    //}
    //
    //
    //#Preview("Anonymous") {
    //    NavigationStack {
    //        MoreView(
    //            store: StoreOf<More>(
    //                initialState: More.State(session: .init(value: .mockAnonymous())),
    //                reducer: {
    //                    More()
    //                }
    //            )
    //        )
    //    }
    //}
}

#warning("Bedre navn og over i design system")
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
            .foregroundStyle(Color.themeDarkGray)
        Text(label)
    }
    .font(.montserratRegular, 13)
    
}
