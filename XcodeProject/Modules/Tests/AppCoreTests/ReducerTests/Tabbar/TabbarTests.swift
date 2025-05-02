//@testable import Tabbar
//import ComposableArchitecture
//import Testing
//import Foundation
//import Model
//import FeedbackFlow
//
//@MainActor
//struct TabbarTests {
//
//    @Test
//    func testAnonymousCreateEventTriggersLoginAlert() async {
//        let session = Shared(Session(account: .anonymous))
//        let store = TestStore(initialState: Tabbar.State(session: session)) {
//            Tabbar()
//        }
//
//        await store.send(.toolbar(.createEventButtonTap)) {
//            $0.destination = .alert(
//                .init(
//                    title: { TextState("Login required") },
//                    actions: {
//                        ButtonState(action: .confirmedToCreateUser, label: { TextState("Create account") })
//                        ButtonState(role: .cancel, label: { TextState("Not now") })
//                    },
//                    message: { TextState("Create an account to access your own events") }
//                )
//            )
//        }
//    }
//
//    @Test
//    func testLoginCreateEventNavigatesToCreateEventScreen() async {
//        let session = Shared(Session.mockWithAccount())
//        let store = TestStore(initialState: Tabbar.State(session: session)) {
//            Tabbar()
//        }
//
//        await store.send(.toolbar(.createEventButtonTap)) {
//            $0.destination = .createEvent(CreateEvent.State(session: session))
//        }
//    }
//
//    @Test
//    func testJoinEventButtonTapPresentsJoinEvent() async {
//        let session = Shared(Session.mockWithAccount())
//        let store = TestStore(initialState: Tabbar.State(session: session)) {
//            Tabbar()
//        }
//
//        await store.send(.toolbar(.joinEventButtonTap)) {
//            $0.destination = .joinEvent(.init())
//        }
//    }
//
//    @Test
//    func testLogoutConfirmationDialogAndConfirmation() async {
//        let session = Shared(Session.mockWithAccount())
//        let store = TestStore(initialState: Tabbar.State(session: session)) {
//            Tabbar()
//        }
//
//        await store.send(.signOutButtonTapped) {
//            $0.destination = .confirmationDialog(
//                ConfirmationDialogState(
//                    title: { TextState("Are you sure you want to logout?") },
//                    actions: {
//                        ButtonState(role: .cancel, label: { TextState("Cancel") })
//                        ButtonState(role: .destructive, action: .logoutConfirmed, label: { TextState("Logout") })
//                    }
//                )
//            )
//        }
//
//        await store.send(.destination(.presented(.confirmationDialog(.logoutConfirmed))))
//        await store.receive(\.delegate(.navigateToSignUp))
//    }
//
//    @Test
//    func testAlertConfirmedToCreateUserNavigatesToSignUp() async {
//        let session = Shared(Session.mockWithAccount())
//        let store = TestStore(initialState: Tabbar.State(session: session)) {
//            Tabbar()
//        }
//
//        await store.send(.destination(.presented(.alert(.confirmedToCreateUser))))
//        await store.receive(\.delegate(.navigateToSignUp))
//    }
//
//    @Test
//    func testStartFeedbackFromEnterCodeTriggersFeedbackFlow() async {
//        let session = Shared(Session.mockWithAccount())
//        let pinCode = PinCode(value: "1234")
//        let feedbackSession = FeedbackSession.mock
//
//        let store = TestStore(initialState: Tabbar.State(session: session)) {
//            Tabbar()
//        } withDependencies: {
//            $0.apiClient.startFeedbackSession = { _ in feedbackSession }
//        }
//
//        await store.send(.enterCode(.delegate(.startFeedback(pinCode))))
//        await store.receive(\.initialiseFeedback(.startFeedback(pinCode: pinCode)))
//        await store.receive(\.initialiseFeedback(.startFeedbackSessionResponse(feedbackSession))) {
//            $0.initialiseFeedback.destination = .feedbackFeature(FeedbackFlow.State.initialState(feedbackSession: feedbackSession))
//        }
//        await store.receive(\.initialiseFeedback(.delegate(.stopLoading))) {
//            $0.enterCode.startFeedbackPincodeInFlight = false
//            $0.participantEvents.startFeedbackPincodeInFlight = nil
//            $0.managerEvents.participantEvents.startFeedbackPincodeInFlight = nil
//        }
//    }
//}
