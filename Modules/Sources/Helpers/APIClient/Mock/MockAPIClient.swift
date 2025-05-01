import Foundation

public extension APIClient {
    static func mock() -> Self {
        
        let mockSessionEngine = MockSessionEngine()
        
        return Self(
            deleteAccount: {
            },
            updateAccount: { _, _, _ in },
            updateFcmToken: { _ in },
            getSession: {
                try await Task.sleep(for: .seconds(1))
                return await mockSessionEngine.session
            },
            startFeedbackSession: { _ in
                try await Task.sleep(for: .seconds(1))
                return .mock
            },
            sendFeedback: { _, _ in
                try await Task.sleep(for: .seconds(1))
                return true
            },
            createEvent: { eventInput in
                try await Task.sleep(for: .seconds(1))
                let id = UUID()
                await mockSessionEngine.appendManagerEvent(input: eventInput, id: id, ownerInfo: OwnerInfo.mock())
                try await Task.sleep(for: .seconds(1))
                let event = await mockSessionEngine.session.getManagerEventId(id)
                return event
            },
            updateEvent: { eventInput, id in
                try await Task.sleep(for: .seconds(1))
                await mockSessionEngine.updateManagerEvent(eventInput, id)
                let event = await mockSessionEngine.session.getManagerEventId(id)
                return event
            },
            deleteEvent: { id in
                try await Task.sleep(for: .seconds(1))
                await mockSessionEngine.deleteEvent(id)
                return ()
            },
            createAccount: { _ in
                try await Task.sleep(for: .seconds(1))
                return await mockSessionEngine.session
            },
            sessionChangedListener: {
                await mockSessionEngine.stream()
            },
            joinEvent: { pinCode in
                try await Task.sleep(for: .seconds(1))
                await mockSessionEngine.appendParticipantEvent(pinCode)
            },
            markEventAsSeen: { _ in
                return ()
            },
            updateAccountRole: { _ in
                return ()
            },
            getMockToken: { "mock_token" },
            getUpdatedSession: { .mock },
            markActivityAsSeen: { }
        )
    }
}
