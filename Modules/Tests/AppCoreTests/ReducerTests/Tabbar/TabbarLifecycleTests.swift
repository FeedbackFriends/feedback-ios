//@testable import Tabbar
//import ComposableArchitecture
//import Testing
//import Foundation
//import Helpers
//
//@MainActor
//struct TabbarLifecycleTests {
//
//    @Test
//    func testNotificationPromptTriggeredOnAppear() async {
//        let session = Shared(Session(participantEvents: <#T##IdentifiedArrayOf<ParticipantEvent>#>, managerData: <#T##ManagerData?#>, accountInfo: <#T##AccountInfo#>, role: <#T##Role?#>))
//
//        let store = TestStore(initialState: TabbarLifecycle.State(session: session)) {
//            TabbarLifecycle()
//        } withDependencies: {
//            $0.notificationClient.shouldPromptForAuthorization = { _ in true }
//            $0.apiClient.sessionChangedListener = {
//                AsyncStream { continuation in
//                    continuation.finish()
//                }
//            }
//            $0.clock = ImmediateClock()
//        }
//
//        await store.send(.onAppear)
//        await store.receive(\.presentNotificationPermissionPrompt)
//        await store.receive(\.delegate(.navigateToNotificationPermissionPrompt))
//    }
//
//    @Test
//    func testUpdatedSessionWithManagerEventsShowsBanner() async {
//        let clock = TestClock()
//        let session = Shared(Session(account: .registered(.init(id: UUID(), email: "x", name: "y"))))
//        let updatedEvent = Event.mock(title: "Sprint Review")
//        let updatedSession = UpdatedSession(
//            updatedManagerEvents: [updatedEvent],
//            updatedParticipantEvents: nil
//        )
//
//        let store = TestStore(initialState: TabbarLifecycle.State(session: session)) {
//            TabbarLifecycle()
//        } withDependencies: {
//            $0.apiClient.getUpdatedSession = { updatedSession }
//            $0.apiClient.sessionChangedListener = {
//                AsyncStream { continuation in continuation.finish() }
//            }
//            $0.clock = clock
//        }
//
//        await store.send(.onAppear)
//        await clock.advance(by: .seconds(10))
//        await store.receive(\.updatedSessionResponse(updatedSession)) {
//            $0.firstFetchAfterEnteringForeground = false
//            $0.bannerState = .serverError("New feedback on event 'Sprint Review'")
//        }
//
//        await clock.advance(by: .seconds(5))
//        await store.receive(\.removeBanner) {
//            $0.bannerState = nil
//        }
//    }
//
//    @Test
//    func testSessionUpdatedTriggersDelegate() async {
//        let newSession = Session.mockWithAccount()
//        let session = Shared(newSession)
//
//        let store = TestStore(initialState: TabbarLifecycle.State(session: session)) {
//            TabbarLifecycle()
//        }
//
//        await store.send(.sessionUpdated(newSession))
//        await store.receive(\.delegate(.updateSession(newSession)))
//    }
//}
//
//extension Event {
//    static func mock(title: String = "Mock Event") -> Event {
//        .init(
//            id: UUID(),
//            title: title,
//            date: .init(),
//            location: "Office",
//            description: "Sprint Review",
//            ownerId: UUID(),
//            feedbackDeadline: nil
//        )
//    }
//}
//
//extension Session {
//    static func mockWithAccount() -> Self {
//        .init(account: .registered(.init(id: UUID(), email: "me@test.com", name: "Me")))
//    }
//}
