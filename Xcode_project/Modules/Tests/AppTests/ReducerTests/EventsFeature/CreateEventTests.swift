@testable import EventsFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

struct CreateEventTests {
    @Test
    func createEventSuccess() async {
        let mockEvent = ManagerEvent.mock()
        
		let store = await TestStore(initialState: CreateEvent.State(recentlyUsedQuestions: .init([]))) {
            CreateEvent()
        } withDependencies: {
            $0.apiClient.createEvent = { _ in mockEvent }
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.createEventButtonTap) {
            $0.createEventRequestInFlight = true
        }
        
        await store.receive(\.createEventResponse) {
            $0.createEventRequestInFlight = false
            $0.showSuccessOverlay = true
        }
        await store.receive(\.delegate, .dismissAndNavigateToDetail(mockEvent))
    }
    
    @Test
    func createEventFailure() async {
        struct Failure: Error, Equatable {}
        let store = await TestStore(initialState: CreateEvent.State(recentlyUsedQuestions: .init([]))) {
            CreateEvent()
        } withDependencies: {
            $0.apiClient.createEvent = { _ in throw Failure() }
        }
        
        await store.send(.createEventButtonTap) {
            $0.createEventRequestInFlight = true
        }
        
        await store.receive(\.presentError) {
            $0.createEventRequestInFlight = false
            $0.alert = .init(error: Failure())
        }
    }
}
