@testable import TabbarFeature
@testable import FeedbackFlowFeature
import ComposableArchitecture
import Foundation
import Testing
@testable import Domain
@testable import MoreFeature
@testable import EventsFeature

@MainActor
struct TabbarTests {
    
    @Test
    func `Account section navigate to sign-up delegate is forwarded`() async {
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        }
        
        await store.send(.accountSection(.delegate(.navigateToSignUp)))
        await store.receive(\.delegate, .navigateToSignUp)
    }
    
    @Test
    func `Account section delete account delegate triggers delete account flow`() async {
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        }
        
        await store.send(.accountSection(.delegate(.deleteAccountButtonTapped)))
        await store.receive(\.deleteAccount.deleteAccountButtonTapped) {
            $0.deleteAccount.destination = .alert(
                AlertState<DeleteAccount.Destination.AlertAction>(
                    title: { TextState("Are you sure?") },
                    actions: {
                        ButtonState(
                            role: .destructive,
                            action: .confirmedToDeleteAccount,
                            label: { TextState("Delete account") }
                        )
                        ButtonState(
                            role: .cancel,
                            label: { TextState("Cancel") }
                        )
                    },
                    message: { TextState("All data related to your account will be deleted and cannot be restored. ⚠️") }
                )
            )
        }
    }
    
    @Test
    func `Activity button opens activity list and navigates to event detail`() async {
        let event: ManagerEvent = .mock()
        let sharedSession = Shared<Session>(
            value: .init(
                participantEvents: .init(uniqueElements: []),
                managerData: .init(
                    managerEvents: .init(uniqueElements: [event]),
                    activity: .init(
                        items: [.init(
                            id: UUID(),
                            date: Date(),
                            eventTitle: event.title,
                            eventId: event.id,
                            newFeedbackCount: 2,
                            seenByManager: false
                        )],
                        unseenTotal: 2
                    ),
                    recentlyUsedQuestions: .init(),
                    feedbackSessionHash: UUID()
                ),
                accountInfo: .init(
                    name: nil,
                    email: nil,
                    phoneNumber: nil
                ),
                role: .manager
            )
        )
        let session = sharedSession
        let store = TestStore(initialState: .init(session: session)) {
            Tabbar()
        } withDependencies: {
            $0.apiClient.markActivityAsSeen = {}
        }
        await store.send(.toolbar(.activityButtonTap)) {
            $0.destination = .activity(session.activity.items.wrappedValue)
        }
        await store.send(.activityManagerEventButtonTap(session.activity.items.wrappedValue.first!)) {
            $0.managerEvents.destination = .eventDetail(.init(event: event, session: sharedSession))
        }
    }
    
    @Test
    func `Create event button as manager navigates to create screen and event detail`() async {
        let sharedSession = Shared<Session>(
            value: .mock()
        )
        let createdEvent = ManagerEvent.mock()
        let session = sharedSession
        let store = TestStore(initialState: .init(session: session)) {
            Tabbar()
        }
        await store.send(.toolbar(.createEventButtonTap)) {
            $0.destination = .createEvent(
                .init(
                    eventForm: .init(
                        initialFocus: .title,
                        eventInput: .init(),
                        shouldOpenKeyboardOnAppear: true,
                        recentlyUsedQuestions: .init([]),
                        successOverlayMessage: "Session created"
                    )
                )
            )
        }
        await store.send(.destination(.presented(.createEvent(.delegate(.dismissAndNavigateToDetail(createdEvent)))))) {
            $0.destination = nil
            $0.managerEvents.destination = .eventDetail(
                .init(
                    event: createdEvent,
                    destination: .invite(createdEvent),
                    session: $0.$session
                )
            )
        }
    }
    
    @Test
    func `Notification permission prompt cancel button dismisses prompt`() async {
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        }
        await store.send(.tabbarLifecyle(.delegate(.presentNotificationPermissionPrompt))) {
            $0.destination = .notificationPermissionPrompt
        }
        await store.send(.dimissNotificationPermissionButtonTap) {
            $0.destination = nil
        }
    }
    
    @Test
    func `Notification permission prompt requests authorization successfully`() async {
        let notificationAuthorizationRequested = LockIsolated(false)
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        } withDependencies: {
            $0.notificationClient.requestAuthorization = { @Sendable in
                notificationAuthorizationRequested.setValue(true)
                return true
            }
        }
        await store.send(.tabbarLifecyle(.delegate(.presentNotificationPermissionPrompt))) {
            $0.destination = .notificationPermissionPrompt
        }
        await store.send(.requestNotificationAuthorization) {
            $0.destination = nil
        }
        #expect(notificationAuthorizationRequested.value == true)
    }

    @Test
    func `Start feedback from enter code screen triggers feedback flow`() async {
        let pin = PinCode(value: "123456")
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        }
        store.exhaustivity = .off
        await store.send(.enterCode(.delegate(.startFeedback(pinCode: pin))))
        await store.receive(\.initialiseFeedback.startFeedback, pin)
    }
    
    @Test
    func `Start feedback from manager events triggers feedback flow`() async {
        let pin = PinCode(value: "654321")
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        }
        store.exhaustivity = .off
        await store.send(.managerEvents(.participantEvents(.delegate(.startFeedback(pinCode: pin)))))
        await store.receive(\.initialiseFeedback.startFeedback, pin)
    }
}
