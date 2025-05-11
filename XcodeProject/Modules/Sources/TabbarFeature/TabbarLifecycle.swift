import SwiftUI
import ComposableArchitecture
import Model
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
        @Shared var session: Session
        var firstUpdateSessionFetchAfterEnterForeground = false
        var bannerState: BannerState?
        public init(session: Shared<Session>) {
            self._session = session
        }
    }
    
    public enum Action {
        case onTask
        case updatedSessionResponse(UpdatedSession?)
        case sessionUpdated(Session)
        case removeBanner
        case presentNotificationPermissionPrompt
        case delegate(Delegate)
        case enterForeground
        case enterBackground
        public enum Delegate: Equatable {
            case presentNotificationPermissionPrompt
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.notificationClient) var notificationClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .removeBanner:
                state.bannerState = nil
                return .none
                
            case .presentNotificationPermissionPrompt:
                return .send(.delegate(.presentNotificationPermissionPrompt))
                
            case .sessionUpdated(let session):
                state.$session.withLock {
                    $0 = session
                }
                return .none
                
            case .onTask:
                return .merge(
                    .run { [role = state.session.role] send in
                        if await notificationClient
                            .shouldPromptForAuthorization(role: role) {
                            await send(.presentNotificationPermissionPrompt)
                        }
                        let sessionChangedListener = await apiClient.sessionChangedListener()
                        for await session in sessionChangedListener {
                            await send(.sessionUpdated(session))
                        }
                    },
                    .run { send in
                        for await _ in self.clock.timer(interval: .seconds(10)) {
                            do {
                                let updatedSession = try await apiClient.getUpdatedSession()
                                await send(
                                    .updatedSessionResponse(updatedSession)
                                )
                            } catch {
                                Logger
                                    .debug(
                                        "Failed to send updated session response: \(error)"
                                    )
                            }
                        }
                    }
                )
                
            case .updatedSessionResponse(let updatedSession):
                if state.firstUpdateSessionFetchAfterEnterForeground {
                    state.firstUpdateSessionFetchAfterEnterForeground = false
                    return .none
                }
                guard let updatedSession else { return .none }
                if let updatedManagerEvents = updatedSession.updatedManagerEvents, let first = updatedManagerEvents.first {
                    state.bannerState = .serverError("New feedback on event '\(first.title)'")
                    return .run { send in
                        try await clock.sleep(for: .seconds(5))
                        await send(.removeBanner)
                    }
                }
                return .none
                
            case .delegate:
                return .none
                
            case .enterForeground:
                state.firstUpdateSessionFetchAfterEnterForeground = true
                return .none
                
            case .enterBackground:
                return .none
            }
        }
    }
}
