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
        let draftEventsStore = $store.scope(state: \.destination?.draftEvents, action: \.destination.draftEvents)
        let notificationPermissionPromptStore = $store.scope(
            state: \.destination?.notificationPermissionPrompt,
            action: \.destination.notificationPermissionPrompt
        )
        tabView
            .task {
                await self.store.send(.tabbarLifecyle(.onTask)).finish()
            }
            .sheet(item: createEventStore) { store in
                NavigationStack {
                    CreateEventView(store: store)
                }
            }
            .sheet(item: joinEventStore) { store in
                JoinEventView(store: store)
                    .presentationDetents([.height(300)])
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
            .sheet(item: draftEventsStore) { draftEvents in
                DraftEventsView(store: draftEvents)
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
                    state: \.initialiseFeedback.destination?.feedbackFlowCoordinator,
                    action: \.initialiseFeedback.destination.feedbackFlowCoordinator
                )
            ) { store in
                FeedbackFlowCoordinatorView(
                    store: store,
                    principalToolbarItem: {
                        store.withState { state in
                            Text(state.title)
                                .font(.montserratSemiBold, 12)
                                .foregroundStyle(Color.themeText)
                        }
                    }
                )
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
                switch store.session.account {
                case .manager:
                    managerEventsView
                        .navigationTitle("Sessions")
                        .toolbar {
                            activityToolbarItem(store.session.activityBadgeCount)
                            ToolbarSpacer(.flexible)
                            draftsToolbarItem(store.session.managerData?.draftEvents.count ?? 0)
                            createEventToolbarItem
                        }
                case .participant:
                    participantEventsView
                        .navigationTitle("Sessions")
                        .toolbar {
                            joinEventToolbarItem
                            activityToolbarItem(store.session.activityBadgeCount)
                        }
                case .anonymous:
                    participantEventsView
                        .navigationTitle("Sessions")
                        .toolbar {
                            createEventToolbarItem
                            activityToolbarItem(store.session.activityBadgeCount)
                        }
                }
            }
            .tabItem {
                Image.calendar
                Text("Sessions")
            }
            .tag(Tab.events)
            
            NavigationStack {
                List {
                    Group {
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
                    .listRowBackground(
                        Color.themeSurface
                    )
                }
                .scrollContentBackground(.hidden)
                .background(Color.themeBackground)
                .tint(Color.themeText)
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
                .navigationTitle("Profile")
                .background(Color.themeBackground)
            }
            .tabItem {
                Image.personCropCircle
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
    
    func draftsToolbarItem(_ draftsCount: Int) -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                store.send(.toolbar(.draftEventsButtonTap))
            } label: {
                Text("Drafts")
                    .font(.montserratMedium, 12)
            }
            .badge(draftsCount)
        }
    }
    
    var createEventToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Section {
                    Button {
                        store.send(.toolbar(.createEventButtonTap))
                    } label: {
                        Text("Create session")
                    }
                    
                }
                Section {
                    Button {
                        store.send(.toolbar(.joinEventButtonTap))
                    } label: {
                        Text("Join session")
                    }
                }
            } label: {
                Image.circleFill
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundStyle(Color.themePrimaryAction.gradient)
                    .overlay {
                        Image.plus
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.themeOnPrimaryAction)
                            .fontWeight(.semibold)
                    }
            }
        }
        .sharedBackgroundVisibility(.hidden)
    }
    
    var joinEventToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Join") {
                store.send(.toolbar(.joinEventButtonTap))
            } 
            .buttonStyle(PrimaryTextButtonStyle())
        }
    }
    
    func activityToolbarItem(_ badgeCount: Int) -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                store.send(.toolbar(.activityButtonTap))
            } label: {
                Image.sparkles
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            .badge(badgeCount)
        }
    }
    
    func logoutSection() -> some View {
        Section {
            Button {
                store.send(.signOutButtonTapped)
            } label: {
                listElementView(image: .moreSectionPortraitAndArrowRight, label: "Logout")
            }
            .confirmationDialog(
                $store.scope(
                    state: \.destination?.confirmationDialog,
                    action: \.destination.confirmationDialog
                )
            )
        } footer: {
            Text("\(DeviceInfo().version())(\(DeviceInfo().build()))")
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
                listElementView(image: .moreSectionTrash, label: "Delete account", isLoading: store.deleteAccount.deleteAccountInFlight)
            }
        }
    }
    
    var signUpSection: some View {
        Section {
            Button {
                store.send(.signUpButtonTap)
            } label: {
                listElementView(image: .moreSectionPersonBadgeKey, label: "Sign up")
            }
        } footer: {
            Text("Sign up to get feedback from others and much more")
        }
    }
}

#Preview {
    TabbarView(
        store: StoreOf<Tabbar>.init(initialState: .init(session: .init(value: .mock()))) {
            Tabbar()
        }
    )
}
