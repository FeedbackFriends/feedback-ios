import EventsFeature
import EnterCodeFeature
import SwiftUI
import Foundation
import MoreFeature
import DesignSystem
import Model
import ComposableArchitecture
import SwiftUI
import Utility
import Logger

public enum Tab: Hashable {
    case feedback, events, more
}

@Reducer
public struct Tabbar {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<AlertAction>)
        @ReducerCaseIgnored
        case notificationPermissionPrompt
        @ReducerCaseEphemeral
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        case createEvent(CreateEvent)
        case joinEvent(JoinEvent)
        @ReducerCaseIgnored
        case activity([ActivityItems])
        public enum ConfirmationDialog: Equatable {
            case logoutConfirmed
        }
        public enum AlertAction: Equatable {
            case confirmedToCreateUser
        }
    }
    
    @ObservableState
    public struct State: Equatable {
        
        @Shared public var session: Session
        var tabbarLifecyle: TabbarLifecycle.State
        var enterCode: EnterCode.State
        var moreSection: MoreSection.State
        var accountSection: AccountSection.State
        public var selectedTab: Tab
        var initialiseFeedback: InitialiseFeedback.State
        var managerEvents: ManagerEvents.State
        var participantEvents: ParticipantEvents.State
        var deleteAccount: DeleteAccount.State
        @Presents var destination: Destination.State?
        let appVersion = Bundle.main.versionNumber
        
        public init(
            session: Shared<Session>,
            selectedTab: Tab = .events,
            destination: Destination.State? = nil
        ) {
            self._session = session
            self.enterCode = .init()
            self.selectedTab = selectedTab
            self.moreSection = .init()
            self.accountSection = .init(session: session)
            self.initialiseFeedback = .init()
            self.participantEvents = .init(session: session)
            self.deleteAccount = .init()
            self.managerEvents = .init(session: session)
            self.tabbarLifecyle = .init(session: session)
            self.destination = destination
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case enterCode(EnterCode.Action)
        case moreSection(MoreSection.Action)
        case accountSection(AccountSection.Action)
        case initialiseFeedback(InitialiseFeedback.Action)
        case participantEvents(ParticipantEvents.Action)
        case managerEvents(ManagerEvents.Action)
        case requestNotificationAuthorization
        case dimissNotificationPermissionButtonTap
        case destination(PresentationAction<Destination.Action>)
        case toolbar(Toolbar)
        case delegate(Delegate)
        case signOutButtonTapped
        case signUpButtonTap
        case navigateToManagerEvent(ActivityItems)
        case tabbarLifecyle(TabbarLifecycle.Action)
        case deleteAccount(DeleteAccount.Action)
        public enum Toolbar: Equatable {
            case createEventButtonTap
            case joinEventButtonTap
            case activityButtonTap
        }
        public enum Delegate {
            case startFeedback(pinCode: PinCode)
            case navigateToSignUp
        }
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.notificationClient) var notificationClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.initialiseFeedback, action: \.initialiseFeedback) {
            InitialiseFeedback()
        }
        Scope(state: \.enterCode, action: \.enterCode) {
            EnterCode()
        }
        Scope(state: \.participantEvents, action: \.participantEvents) {
            ParticipantEvents()
        }
        Scope(state: \.managerEvents, action: \.managerEvents) {
            ManagerEvents()
        }
        Scope(state: \.accountSection, action: \.accountSection) {
            AccountSection()
        }
        Scope(state: \.moreSection, action: \.moreSection) {
            MoreSection()
        }
        Scope(state: \.tabbarLifecyle, action: \.tabbarLifecyle) {
            TabbarLifecycle()
        }
        Scope(state: \.deleteAccount, action: \.deleteAccount) {
            DeleteAccount()
        }
        Reduce { state, action in
            switch action {
                
            case .tabbarLifecyle(.delegate(let delegateAction)):
                switch delegateAction {
                case .presentNotificationPermissionPrompt:
                    state.destination = .notificationPermissionPrompt
                }
                return .none
                
            case .tabbarLifecyle:
                return .none
                
            case .navigateToManagerEvent(let activityItem):
                state.managerEvents.destination = .eventDetail(
                    EventDetailFeature.State(
                        event: state.session.unwrappedManagerSession.managerData.managerEvents[id: activityItem.eventId]!,
                        session: state.$session
                    )
                )
                return .run { send in
                    do {
                        try await apiClient.markEventAsSeen(activityItem.id)
                    } catch {
                        Logger.debug("Reset new feedback failed with error: \(error.localizedDescription)")
                    }
                }
                
            case .destination(.presented(.createEvent(.delegate(.dismissAndNavigateToDetail(let event))))):
                state.destination = nil
                state.managerEvents.destination = .eventDetail(
                    EventDetailFeature.State(
                        event: event,
                        session: state.$session,
                        destination: .invite(event)
                    )
                )
                return .none
                
            case .signOutButtonTapped:
            state.destination = .confirmationDialog(
                ConfirmationDialogState<Destination.ConfirmationDialog>(
                    title: { TextState("Are you sure you want to logout?") },
                    actions: {
                        ButtonState(role: .cancel, label: { TextState("Cancel") })
                        ButtonState(role: .destructive, action: .logoutConfirmed, label: { TextState("Logout") })
                    }
                )
            )
            return .none
                
            case .accountSection:
                return .none
                
                
            case .destination(.presented(.alert(let alertAction))):
                switch alertAction {
                case .confirmedToCreateUser:
                    return .send(.delegate(.navigateToSignUp))
                }
                
            case .destination(.presented(.confirmationDialog(let confirmationDialogAction))):
                switch confirmationDialogAction {
                case .logoutConfirmed:
                    return .send(.delegate(.navigateToSignUp))
                }
                             
            case .destination(.presented(.joinEvent(.delegate(.navigateToParticipantEvent(let pinCode))))):
                state.managerEvents.segmentedControl = .participating
                state.managerEvents.participantEvents.destination = .startFeedbackConfirmation(pinCode)
                state.participantEvents.destination = .startFeedbackConfirmation(pinCode)
                return .none
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .enterCode(.delegate(.startFeedback(let pinCode))),
                    .participantEvents(.delegate(.startFeedback(let pinCode))),
                    .managerEvents(.participantEvents(.delegate(.startFeedback(let pinCode)))):
                return .send(.initialiseFeedback(.startFeedback(pinCode: pinCode)))
                
            case .initialiseFeedback(.delegate(let delegateAction)):
                switch delegateAction {
                case .stopLoading:
                    state.enterCode.startFeedbackPincodeInFlight = false
                    state.enterCode.pinCodeInput.value = ""
                    state.participantEvents.startFeedbackPincodeInFlight = nil
                    state.managerEvents.participantEvents.startFeedbackPincodeInFlight = nil
                }
                return .none
                
            case .participantEvents:
                return .none
                
            case .enterCode:
                return .none
                
            case .toolbar(let toolbarButtonAction):
                switch toolbarButtonAction {
                    
                case .createEventButtonTap:
                    if case .anonymous = state.session.account {
                        state.destination = .alert(
                            .init(
                                title: { TextState("Login required") },
                                actions: {
                                    ButtonState(action: .confirmedToCreateUser, label: { TextState("Create account") })
                                    ButtonState(role: .cancel, label: { TextState("Not now") })
                                },
                                message: { TextState("Create an account to access your own events") })
                        )
                        return .none
                    }
                    state.destination = .createEvent(
                        CreateEvent.State(session: state.$session)
                )
                case .joinEventButtonTap:
                    state.destination = .joinEvent(.init())
                case .activityButtonTap:
                    state.destination = .activity(state.session.activity.items)
                    return .run { send in
                        do {
                            try await apiClient.markActivityAsSeen()
                        } catch {
                            Logger.debug("Reset new feedback failed with error: \(error.localizedDescription)")
                        }
                    }
                }
                return .none
                
            case .moreSection:
                return .none
                
            case .initialiseFeedback:
                return .none
                
            case .requestNotificationAuthorization:
                state.destination = nil
                return .run { send in
                    _ = try await notificationClient.requestAuthorization()
                }
            
            case .dimissNotificationPermissionButtonTap:
                state.destination = nil
                return .none
                
            case .signUpButtonTap:
                return .send(.delegate(.navigateToSignUp))
  
            case .delegate:
                return .none
                
            case .managerEvents:
                return .none
                
            case .deleteAccount:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
