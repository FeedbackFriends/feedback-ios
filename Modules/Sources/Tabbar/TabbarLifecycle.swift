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
        case sessionUpdated(NewSession)
        case removeBanner
        case presentNotificationPermissionPrompt
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case navigateToNotificationPermissionPrompt
            case updateSession(NewSession)
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
            switch action {
                
            case .removeBanner:
                state.bannerState = nil
                return .none
                
            case .presentNotificationPermissionPrompt:
                return .send(.delegate(.navigateToNotificationPermissionPrompt))
                
            case .sessionUpdated(let session):
                return .send(.delegate(.updateSession(session)))
                
            case .onAppear:
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
                                if let updatedSession {
                                    await send(
                                        .updatedSessionResponse(updatedSession)
                                    )
                                }
                            } catch {
                                logger
                                    .log(
                                        "Failed to send updated session response: \(error)"
                                    )
                            }
                        }
                    }.cancellable(id: CancelID.timer, cancelInFlight: true)
                )
                
            case .updatedSessionResponse(let updatedSession):
                if !state.firstFetchAfterEnteringForeground {
                    state.firstFetchAfterEnteringForeground = false
                    if let updatedManagerEvents = updatedSession.updatedManagerEvents, let first = updatedManagerEvents.first {
                        state.bannerState = .serverError("New feedback on event '\(first.title)'")
                        return .run { send in
                            try await clock.sleep(for: .seconds(5))
                            await send(.removeBanner)
                        }
                    }
                }
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
