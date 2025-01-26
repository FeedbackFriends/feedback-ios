import EventsFeature
import EnterCode
import SwiftUI
import Foundation
import More
import DesignSystem
import APIClient
import ComposableArchitecture
import SwiftUI

public enum Tab: Hashable {
    case feedback, events, more, teams
}

@Reducer
public struct Tabbar {
    @ObservableState
    public struct State {
        
        public var eventsOverview: EventsOverview.State
        var enterCode: EnterCode.State
        var more: More.State
        public var selectedTab: Tab
        @Shared public var session: Session
        var initialiseFeedback: FeedbackButton.State
        
        
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
        case printSession
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.logClient) var logger
    
    public init() {}
    
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
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                return .run { send in
                    let sessionChangedListener = apiClient.sessionChangedListener()
                    for await session in sessionChangedListener {
                        await send(.sessionUpdated(session))
                    }
                }
                
            case .binding:
                return .none
                
            case .enterCode(.delegate(.startFeedback(let pinCode))),
                    .eventsOverview(.delegate(.startFeedback(let pinCode))):
                return .send(.initialiseFeedback(.startFeedback(pinCode: pinCode)))
                
            case .initialiseFeedback(.delegate(let delegateAction)):
                switch delegateAction {
                case .stopLoading:
                    state.enterCode.startFeedbackInFlight = false
                    state.eventsOverview.startFeedbackInFlight = nil
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
                logger.log("Local session updated: \(session)")
                state.$session.withLock {
                    $0 = session
                }
                return .none
                
            case .printSession:
                dump(state.session)
                return .none
            }
        }
    }
}
