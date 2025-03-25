import EventsFeature
import EnterCode
import SwiftUI
import Foundation
import More
import DesignSystem
import Helpers
import ComposableArchitecture
import SwiftUI

public enum Tab: Hashable {
    case feedback, events, more, teams
}

@Reducer
public struct Tabbar {
    
    @Reducer
    public enum Destination {
        @ReducerCaseIgnored
        case notificationPermissionPrompt
    }
    
    @ObservableState
    public struct State {
        
        public var eventsOverview: EventsOverview.State
        var enterCode: EnterCode.State
        var more: More.State
        public var selectedTab: Tab
        @Shared public var session: Session
        var initialiseFeedback: FeedbackButton.State
        @Presents var destination: Destination.State?
        var inSync: Bool
        
        public init(
            session: Shared<Session>,
            eventsOverview: EventsOverview.State,
            enterCode: EnterCode.State,
            selectedTab: Tab,
            initialiseFeedback: FeedbackButton.State = .init()
        ) {
            self._session = session
            self.eventsOverview = eventsOverview
            self.enterCode = enterCode
            self.selectedTab = selectedTab
            self.more = .init(session: session)
            self.initialiseFeedback = initialiseFeedback
            self.inSync = true
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case enterCode(EnterCode.Action)
        case eventsOverview(EventsOverview.Action)
        case more(More.Action)
        case initialiseFeedback(FeedbackButton.Action)
        case onAppear
        case sessionUpdated(Session)
        case presentNotificationPermissionPrompt
        case requestNotificationAuthorization
        case dimissNotificationPermissionButtonTap
        case destination(PresentationAction<Destination.Action>)
        case didEnterForeground
        case delegate(Delegate)
        case updatedSessionResponse(UpdatedSession)
        public enum Delegate {
            case forceRefreshSession
        }
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.logClient) var logger
    @Dependency(\.continuousClock) var clock
    @Dependency(\.notificationClient) var notificationClient
    
    public init() {}
    
    enum CancelID { case timer }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.initialiseFeedback, action: \.initialiseFeedback) {
            FeedbackButton()
        }
        Scope(state: \.enterCode, action: \.enterCode) {
            EnterCode()
        }
        Scope(state: \.eventsOverview, action: \.eventsOverview) {
            EventsOverview()
        }
        Scope(state: \.more, action: \.more) {
            More()
        }
        Reduce {
            state,
            action in
            switch action {
                
            case .didEnterForeground:
                state.inSync = false
                return .none
                
            case .onAppear:
                return .merge(
                    .run { [role = state.session.role] send in
                        if await notificationClient.shouldPromptForAuthorization(role: role) {
                            await send(.presentNotificationPermissionPrompt)
                        }
                        let sessionChangedListener = await apiClient.sessionChangedListener()
                        for await session in sessionChangedListener {
                            await send(.sessionUpdated(session))
                        }
                    },
                    .run {  send in
                        for await _ in self.clock.timer(interval: .seconds(5)) {
                            do {
                                let updatedSession = try await apiClient.getUpdatedSession()
                                await send(.updatedSessionResponse(updatedSession))
                            } catch {
                                logger.log("Failed to send updated session response: \(error)")
                            }
                        }
                    }.cancellable(id: CancelID.timer, cancelInFlight: true)
                )
                
            case .updatedSessionResponse(let updatedSession):
                if let first = updatedSession.events.first {
                    notificationClient.scheduleLocalNotification(
                        title: "New feedback 🤝",
                        body: "Feedback received on event '\(first.title)'",
                        userInfo: [:],
                        presentAfterDelayInSeconds: 1,
                        id: "NewFeedback"
                    )
                }
                return .none
                
            case .binding:
                return .none
                
            case .enterCode(.delegate(.startFeedback(let pinCode))),
                    .eventsOverview(.delegate(.startFeedback(let pinCode))):
                return .send(.initialiseFeedback(.startFeedback(pinCode: pinCode)))
                
            case .initialiseFeedback(.delegate(let delegateAction)):
                switch delegateAction {
                case .stopLoading:
                    state.enterCode.startFeedbackPincodeInFlight = false
                    state.eventsOverview.startFeedbackPincodeInFlight = nil
                }
                return .none
                
            case .enterCode:
                return .none
                
            case .eventsOverview:
                return .none
            
            case .more:
                return .none
                
            case .initialiseFeedback:
                return .none
                
            case .sessionUpdated(let session):
                state.$session.withLock {
                    $0 = session
                }
                guard case .manager(let managerData, _) = state.session.userType else { return .none }
                if case .eventDetail(let detailState) = state.eventsOverview.destination {
                    state.eventsOverview.destination = .eventDetail(
                        EventDetailFeature.State(
                            event: managerData.managerEvents[id: detailState.event.id]!,
                            session: state.$session
                        )
                    )
                }
                return .none
                
            case .presentNotificationPermissionPrompt:
                state.destination = .notificationPermissionPrompt
                return .none
                
            case .requestNotificationAuthorization:
                state.destination = nil
                return .run { send in
                    _ = try await notificationClient.requestAuthorization()
                }
            
            case .dimissNotificationPermissionButtonTap:
                state.destination = nil
                return .none
                
            case .destination:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
