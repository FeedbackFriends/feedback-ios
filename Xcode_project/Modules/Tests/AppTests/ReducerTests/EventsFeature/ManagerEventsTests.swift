@testable import EventsFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct ManagerEventsTests {
    
    @Test
    func managerEvent_eventDetail() async {
        let session: Shared<Session> = .init(value: .mock(numberOfManagerEvents: 2))
        let mockEvent = session.wrappedValue.managerData!.managerEvents[0]
        var eventMarkedAsSeen: UUID?
        
        let store = TestStore(initialState: ManagerEvents.State(session: session)) {
            ManagerEvents()
        } withDependencies: {
            $0.apiClient.markEventAsSeen = { @MainActor in
                eventMarkedAsSeen = $0
            }
            $0.webURLClient.inviteUrl = { _ in
                     URL(string: "https://example.com")!
            }
        }
        
        await store.send(.managerEventTap(mockEvent)) {
            $0.destination = .eventDetail(
                EventDetailFeature.State.init(
                    event: mockEvent,
                    session: session
                )
            )
        }
        #expect(eventMarkedAsSeen == nil, "Event not marked as seen when tapped")
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
        #expect(eventMarkedAsSeen == mockEvent.id, "Event should be marked as seen when navigating back from detail")
    }
}
