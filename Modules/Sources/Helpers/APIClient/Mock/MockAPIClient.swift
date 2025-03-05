import Foundation

public extension APIClient {
    static func mock() -> Self {
        
        let mockSessionEngine = MockSessionEngine()
        
        return Self(
            deleteAccount: { },
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
                return await mockSessionEngine.session.getManagerEventId(id)
            },
            updateEvent: { eventInput, id in
                try await Task.sleep(for: .seconds(1))
                await mockSessionEngine.updateManagerEvent(eventInput, id)
                return await mockSessionEngine.session.getManagerEventId(id)
                
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
            joinEvent: { eventCode in
                try await Task.sleep(for: .seconds(1))
                await mockSessionEngine.appendParticipantEvent(eventCode)
            },
            resetNewFeedbackForEvent: { eventCode in
                return ()
            },
            updateAccountRole: { _ in
                return ()
            },
            getMockToken: { "mock_token" }
        )
    }
}
