import EnterCodeFeature
import EventsFeature
import MoreFeature
import DesignSystem
import SwiftUI
import ComposableArchitecture
import FeedbackFlowFeature
import Utility

public struct TabbarView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var store: StoreOf<Tabbar>
    
    public init(store: StoreOf<Tabbar>) {
        self.store = store
    }
    
    public var body: some View {
        let createEventStore = $store.scope(state: \.destination?.createEvent, action: \.destination.createEvent)
        let joinEventStore = $store.scope(state: \.destination?.joinEvent, action: \.destination.joinEvent)
        let activityStore = $store.scope(state: \.destination?.activity, action: \.destination.activity)
        let notificationPermissionPromptStore = $store.scope(
            state: \.destination?.notificationPermissionPrompt,
            action: \.destination.notificationPermissionPrompt
        )
        tabView
            .task {
                await self.store.send(.tabbarLifecyle(.onTask)).finish()
            }
            .toolbarBackground(
                Color.themeBackground,
                for: .tabBar
            )
            .confirmationDialog(
                $store.scope(
                    state: \.destination?.confirmationDialog,
                    action: \.destination.confirmationDialog
                )
            )
            .sheet(item: createEventStore) { store in
                NavigationStack {
                    CreateEventView(store: store)
                }
            }
            .sheet(item: joinEventStore) { store in
                JoinEventView(store: store)
                    .presentationDetents([.height(270)])
            }
            .sheet(item: activityStore) { activityItems in
                activityItems.withState { activityItems in
                    ActivityView(
                        activityItems: activityItems,
                        activityManagerEventButtonTap: {
                            store.send(.activityManagerEventButtonTap($0))
                        }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            .animation(.bouncy, value: store.session)
            .banner(unwrapping: store.tabbarLifecyle.bannerState)
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .alert($store.scope(state: \.initialiseFeedback.destination?.alert, action: \.initialiseFeedback.destination.alert))
            .alert($store.scope(state: \.deleteAccount.destination?.alert, action: \.deleteAccount.destination.alert))
            .sheet(
                item: notificationPermissionPromptStore
            ) { _ in
                NotificationPermissionView(
                    requestAuthorizationButtonTap: {
                        store.send(.requestNotificationAuthorization)
                    },
                    dismissButtonTap: {
                        store.send(.dimissNotificationPermissionButtonTap)
                    }
                )
                .presentationDetents([.height(600)])
            }
            .fullScreenCover(
                item: $store.scope(
                    state: \.initialiseFeedback.destination?.feedbackFeature,
                    action: \.initialiseFeedback.destination.feedbackFeature
                )
            ) { store in
                FeedbackFlowView(store: store)
            }
    }
}

private extension TabbarView {
    
    var tabView: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                EnterCodeView(store: store.scope(state: \.enterCode, action: \.enterCode))
            }
            .tabItem {
                Image.handshake
                    .renderingMode(.template)
                    .imageScale(.small)
                Text("Feedback")
            }
            .tag(Tab.feedback)
            
            NavigationStack {
                Group {
                    switch store.session.account {
                    case .manager:
                        managerEventsView
                            .toolbar {
                                createEventToolbarItem
                                activityToolbarItem(store.session.activityBadgeCount)
                            }
                    case .participant:
                        participantEventsView
                            .toolbar {
                                joinEventToolbarItem
                                activityToolbarItem(store.session.activityBadgeCount)
                            }
                    case .anonymous:
                        participantEventsView
                            .toolbar {
                                createEventToolbarItem
                                activityToolbarItem(store.session.activityBadgeCount)
                            }
                    }
                }.navigationTitle("Events")
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Events")
            }
            .tag(Tab.events)
            
            NavigationStack {
                List {
                    switch store.session.account {
                    case .manager, .participant:
                        AccountSectionView(store: store.scope(state: \.accountSection, action: \.accountSection))
                    case .anonymous:
                        EmptyView()
                    }
                    MoreSectionView(store: store.scope(state: \.moreSection, action: \.moreSection))
                    switch store.session.account {
                    case .manager, .participant:
                        logoutSection()
                        deleteAccountSection()
                    case .anonymous:
                        signUpSection
                    }
                }
                .navigationDestination(
                    item: $store.scope(
                        state: \.accountSection.destination?.modifyAccount,
                        action: \.accountSection.destination.modifyAccount
                    )
                ) { store in
                    ModifyAccountView(store: store)
                }
                .sheet(
                    item: $store.scope(
                        state: \.accountSection.destination?.changeUserType,
                        action: \.accountSection.destination.changeUserType
                    )
                ) { store in
                    ChangeUserTypeView(store: store)
                        .presentationDetents([.height(240)])
                }
                .scrollContentBackground(.hidden)
                .background(Color.themeBackground)
                .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
            .tag(Tab.more)
        }
    }
    
    var participantEventsView: some View {
        ParticipantEventsView(
            store: store.scope(
                state: \.participantEvents,
                action: \.participantEvents
            )
        )
    }
    
    var managerEventsView: some View {
        ManagerEventsView(
            store: store.scope(state: \.managerEvents, action: \.managerEvents)
        )
        .tag(SegmentedControlMenu.yourEvents)
    }
    
    var createEventToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Section {
                    Button {
                        store.send(.toolbar(.createEventButtonTap))
                    } label: {
                        Text("Create event")
                    }
                    
                }
                Section {
                    Button {
                        store.send(.toolbar(.joinEventButtonTap))
                    } label: {
                        Text("Join event")
                    }
                }
                
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundStyle(Color.themePrimaryAction.gradient)
            }
        }
    }
    
    var joinEventToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                store.send(.toolbar(.joinEventButtonTap))
            } label: {
                Text("Join")
            }
            .buttonStyle(PrimaryToolbarButtonStyle())
        }
    }
    
    func activityToolbarItem(_ count: Int) -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                store.send(.toolbar(.activityButtonTap))
            } label: {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(IconToolbarStyle())
            .overlay(alignment: .bottomTrailing) {
				if count > 0 {
                    Text(count.description)
                        .foregroundStyle(Color.themeWhite)
                        .font(.montserratSemiBold, 10)
                        .padding(6)
                        .background(Circle().foregroundStyle(Color.themeRed))
                        .offset(x: 7, y: 7)
                }
            }
        }
    }
    
    func logoutSection() -> some View {
        Section {
            Button {
                store.send(.signOutButtonTapped)
            } label: {
                listElementView(image: "rectangle.portrait.and.arrow.right", label: "Logout")
            }
        } footer: {
            Text("\(DeviceInfo().version())")
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .font(.montserratThin, 12)
                .padding(.vertical, 20)
        }
    }
    
    func deleteAccountSection() -> some View {
        Section {
            Button {
                store.send(.deleteAccount(.deleteAccountButtonTapped))
            } label: {
                listElementView(image: "trash", label: "Delete account", isLoading: store.deleteAccount.deleteAccountInFlight)
            }
        }
    }
    
    var signUpSection: some View {
        Section {
            Button {
                store.send(.signUpButtonTap)
            } label: {
                listElementView(image: "person.badge.key", label: "Sign up")
            }
        } footer: {
            Text("Sign up to get feedback from others and much more")
        }
    }
}
