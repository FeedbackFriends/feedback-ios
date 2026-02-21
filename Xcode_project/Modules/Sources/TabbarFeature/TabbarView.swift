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
                resetSelectedTabIfNeeded()
            }
            .overlay(alignment: .bottomTrailing) {
                if shouldShowJoinFloatingActionButton {
                    joinFloatingActionButton
                        .padding(.trailing, 20)
                        .padding(.bottom, 80)
                }
            }
            .onChange(of: scenePhase) { _, newValue in
                switch newValue {
                case .active:
                    store.send(.tabbarLifecyle(.enterForeground))
                case .background:
                    store.send(.tabbarLifecyle(.enterBackground))
                case .inactive:
                    break
                @unknown default:
                    break
                }
            }
            .onChange(of: store.session.role) { _, _ in
                presentWelcomeOnboardingIfNeeded()
                resetSelectedTabIfNeeded()
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
    var isManager: Bool {
        if case .manager = store.session.account {
            return true
        }
        return false
    }
    
    var tabView: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                feedbackTabContent
                    .navigationTitle("Give Feedback")
            }
            .tabItem {
                Image.letsGrowIconTab
                Text("Give Feedback")
            }
            .tag(Tab.feedback)
            
            if isManager {
                NavigationStack {
                    managerEventsView
                        .navigationTitle("My sessions")
                        .toolbar {
                            activityToolbarItem(store.session.activityBadgeCount)
                            welcomeOnboardingToolbarItem
                        }
                }
                .tabItem {
                    Image.calendar
                    Text("My sessions")
                }
                .tag(Tab.events)
            }
            
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
            Text("Sign up to receive feedback from others")
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

    var feedbackEmptyStateView: some View {
        ScrollView {
            EmptyStateView(
                title: "No feedback requests yet",
                message: "When someone invites you, feedback requests will appear here. You can also join a session with a PIN."
            )
            .padding(.horizontal, Theme.padding)
        }
        .background(Color.themeBackground)
    }
    
    var shouldShowJoinFloatingActionButton: Bool {
        store.selectedTab == .feedback
    }
    
    var joinFloatingActionButton: some View {
        Button {
            store.send(.toolbar(.joinEventButtonTap))
        } label: {
            Text("Join with PIN")
            .font(.montserratSemiBold, 15)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .foregroundStyle(Color.themeOnPrimaryAction)
            .background(Color.themePrimaryAction.gradient, in: Capsule())
        }
    }

    func presentWelcomeOnboardingIfNeeded() {
        guard store.session.role == .manager else { return }
        guard !hasSeenWelcomeOnboarding else { return }
        isShowingWelcomeOnboarding = true
    }

    func resetSelectedTabIfNeeded() {
        guard !isManager else { return }
        guard store.selectedTab == .events else { return }
        store.selectedTab = .feedback
    }
}

#Preview {
    TabbarView(
        store: StoreOf<Tabbar>.init(initialState: .init(session: .init(value: .mock()))) {
            Tabbar()
        }
    )
}
