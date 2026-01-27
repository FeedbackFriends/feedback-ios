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
    @AppStorage("hasSeenWelcomeOnboarding") private var hasSeenWelcomeOnboarding = false
    @State private var isShowingWelcomeOnboarding = false
    
    public init(store: StoreOf<Tabbar>) {
        self.store = store
    }
    
    public var body: some View {
        let joinEventStore = $store.scope(state: \.destination?.joinEvent, action: \.destination.joinEvent)
        let activityStore = $store.scope(state: \.destination?.activity, action: \.destination.activity)
        let notificationPermissionPromptStore = $store.scope(
            state: \.destination?.notificationPermissionPrompt,
            action: \.destination.notificationPermissionPrompt
        )
        tabView
            .task {
                await self.store.send(.tabbarLifecyle(.onTask)).finish()
                presentWelcomeOnboardingIfNeeded()
            }
            .onChange(of: store.session.role) { _, _ in
                presentWelcomeOnboardingIfNeeded()
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
            .sheet(isPresented: $isShowingWelcomeOnboarding, onDismiss: {
                hasSeenWelcomeOnboarding = true
            }) {
                WelcomeOnboardingView(
                    accountEmail: store.session.accountInfo.email,
                    primaryAction: {
                        hasSeenWelcomeOnboarding = true
                        isShowingWelcomeOnboarding = false
                    }
                )
                .interactiveDismissDisabled()
                .presentationDragIndicator(.hidden)
            }
    }
}

private extension TabbarView {
    
    var tabView: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                feedbackTabContent
                    .navigationTitle("Give Feedback")
                    .toolbar {
                        joinEventToolbarItem
                    }
            }
            .tabItem {
                Image.handshake
                    .renderingMode(.template)
                    .imageScale(.small)
                Text("Give Feedback")
            }
            .tag(Tab.feedback)
            
            NavigationStack {
                switch store.session.account {
                case .manager:
                    managerEventsView
                        .navigationTitle("My sessions")
                        .toolbar {
                            activityToolbarItem(store.session.activityBadgeCount)
                            welcomeOnboardingToolbarItem
                        }
                case .participant:
                    eventsEmptyStateView
                        .navigationTitle("My sessions")
                case .anonymous:
                    eventsEmptyStateView
                        .navigationTitle("My sessions")
                }
            }
            .tabItem {
                Image.calendar
                Text("My sessions")
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

    var welcomeOnboardingToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isShowingWelcomeOnboarding = true
            } label: {
                Image.questionmarkCircle
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            .accessibilityLabel(Text("Welcome"))
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

    var feedbackTabContent: some View {
        Group {
            switch store.session.account {
            case .participant:
                participantEventsView
            case .manager, .anonymous:
                feedbackEmptyStateView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.themeBackground.ignoresSafeArea())
    }

    var eventsEmptyStateView: some View {
        ScrollView {
            EmptyStateView(
                title: "Sessions are for managers",
                message: "Use the Give Feedback tab to join meetings and share feedback."
            )
            .padding(.horizontal, Theme.padding)
        }
        .background(Color.themeBackground)
    }
    
    var feedbackEmptyStateView: some View {
        ScrollView {
            EmptyStateView(
                title: "No feedback yet",
                message: "When you're invited to share feedback, requests will appear here."
            )
            .padding(.horizontal, Theme.padding)
        }
        .background(Color.themeBackground)
    }

    var joinEventToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                store.send(.toolbar(.joinEventButtonTap))
            } label: {
                HStack(spacing: 6) {
                    Image.lockFill
                        .renderingMode(.template)
                        .imageScale(.small)
                    Text("Join")
                }
            }
            .buttonStyle(PrimaryTextButtonStyle())
        }
    }

    func presentWelcomeOnboardingIfNeeded() {
        guard store.session.role == .manager else { return }
        guard !hasSeenWelcomeOnboarding else { return }
        isShowingWelcomeOnboarding = true
    }
}

#Preview {
    TabbarView(
        store: StoreOf<Tabbar>.init(initialState: .init(session: .init(value: .mock()))) {
            Tabbar()
        }
    )
}
