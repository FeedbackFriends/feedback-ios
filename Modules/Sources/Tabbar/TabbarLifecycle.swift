import SwiftUI
import ComposableArchitecture
import Helpers
import DesignSystem
import Logger

@Reducer
public struct TabbarLifecycle {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Shared var session: NewSession
        var firstFetchAfterEnteringForeground = false
        var bannerState: BannerState?
        public init(session: Shared<NewSession>) {
            self._session = session
        }
    }
    
    public enum Action {
        case onAppear
        case updatedSessionResponse(UpdatedSession)
        case didEnterForeground
        case sessionUpdated(NewSession)
        case removeBanner
        case presentNotificationPermissionPrompt
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case navigateToNotificationPermissionPrompt
//            case updateManagerEventDetail(withEvent: ManagerEvent)
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.logClient) var logger
    
    enum CancelID { case timer }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
//            switch action {
//                
//            case .removeBanner:
//                state.bannerState = nil
//                return .none
//                
//            case .presentNotificationPermissionPrompt:
//                return .send(.delegate(.navigateToNotificationPermissionPrompt))
//                
//            case .sessionUpdated(let session):
////                state.$session.withLock {
////                    $0 = session
////                }
////#warning("Fix me")
////                guard
////                    case .manager(let managerData, _) = state.session.account,
////                    case .eventDetail(let eventState) = state.eventsOverview.destination
////                else { return .none }
////                var mutableEventState = eventState
////                if let event = managerData.managerEvents[id: eventState.event.id] {
////                    mutableEventState.event = event
////                }
////                state.eventsOverview.destination = .eventDetail(mutableEventState)
//                return .none
//                
//            case .didEnterForeground:
//                state.firstFetchAfterEnteringForeground = true
//                return .none
//                
//            case .onAppear:
//                return .none
////                return .merge(
////                    .run { [role = state.session.role] send in
////                        if await notificationClient
////                            .shouldPromptForAuthorization(role: role) {
////                            await send(.presentNotificationPermissionPrompt)
////                        }
////                        let sessionChangedListener = await apiClient.sessionChangedListener()
////                        for await session in sessionChangedListener {
////                            await send(.sessionUpdated(session))
////                        }
////                    },
////                    .run {  send in
////                        for await _ in self.clock.timer(interval: .seconds(5)) {
////                            do {
//////                                let updatedSession = try await apiClient.getUpdatedSession()
//////                                await send(
//////                                    .updatedSessionResponse(updatedSession)
//////                                )
////                            } catch {
////                                logger
////                                    .log(
////                                        "Failed to send updated session response: \(error)"
////                                    )
////                            }
////                        }
////                    }.cancellable(id: CancelID.timer, cancelInFlight: true)
////                )
//                
//            case .updatedSessionResponse(let updatedSession):
//                if !state.firstFetchAfterEnteringForeground {
//                    state.firstFetchAfterEnteringForeground = false
//                    if let first = updatedSession.events.first {
//                        state.bannerState = .serverError("New feedback on event '\(first.title)'")
//                        return .run { send in
//                            try await clock.sleep(for: .seconds(5))
//                            await send(.removeBanner)
//                        }
//                    }
//                }
//                return .none
//                
//            case .delegate:
//                return .none
//            }
        }
    }
}
