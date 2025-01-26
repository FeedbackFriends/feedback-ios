import Foundation

fileprivate var session = Session.mock(numberOfManagerEvents: 99)
fileprivate var sessionContinuation: AsyncStream<Session>.Continuation!

public extension APIClient {
    static let mock = Self(
        deleteAccount: {},
        updateAccount: { _, _, _ in },
        updateFcmToken: { _ in },
        getSession: {
            try await Task.sleep(for: .seconds(1))
            return session
        },
        startFeedbackSession: { _ in
            try await Task.sleep(for: .seconds(1))
            return .mock
        },
        _sendFeedback: { _, _ in
            try await Task.sleep(for: .seconds(1))
            return true
        },
        createEvent: { eventInput in
            try await Task.sleep(for: .seconds(1))
            let id = UUID()
            session.appendManagerEvent(input: eventInput, id: id, ownerInfo: OwnerInfo.mock())
            try await Task.sleep(for: .seconds(1))
            return session.getManagerEventId(id)
        },
        updateEvent: { eventInput, id in
            try await Task.sleep(for: .seconds(1))
            session.updateManagerEvent(eventInput, id)
            return session.getManagerEventId(id)
            
        },
        deleteEvent: { id in
            try await Task.sleep(for: .seconds(1))
            session.deleteEvent(id)
            return ()
        },
        createAccount: { _ in
            try await Task.sleep(for: .seconds(1))
            return session
        },
        sessionChangedListener: {
            AsyncStream {
                sessionContinuation = $0
            }
        },
        joinEvent: { eventCode in
            try await Task.sleep(for: .seconds(1))
            session.appendParticipantEvent(eventCode)
        },
        resetNewFeedbackForEvent: { eventCode in
            return ()
        }
    )
}

private extension Session {
    
    mutating func updateManagerEvent(_ input: EventInput, _ id: UUID) {
        guard case let .manager(managerData: managerData, accountInfo: accountInfo) = self.userType else { return }
        var mutableManagerData = managerData
        mutableManagerData.managerEvents[id: id]?.title = input.title
        mutableManagerData.managerEvents[id: id]?.date = input.date
        mutableManagerData.managerEvents[id: id]?.durationInMinutes = input.durationInMinutes
        mutableManagerData.managerEvents[id: id]?.questions = input.questions.map {
            .init(
                id: UUID(),
                questionText: $0.questionText,
                feedbackType: $0.feedbackType,
                feedback: nil,
                feedbackSummary: nil,
                newFeedbackForQuestion: 0
            )
        }
        mutableManagerData.managerEvents[id: id]?.agenda = input.agenda
        mutableManagerData.managerEvents[id: id]?.location = input.location
        self.userType = .manager(managerData: mutableManagerData, accountInfo: accountInfo)
    }
    
    mutating func appendManagerEvent(input: EventInput, id: UUID, ownerInfo: OwnerInfo) {
        guard case let .manager(managerData: managerData, accountInfo: accountInfo) = self.userType else { return }
        var mutableManagerData = managerData
        let managerEvent = ManagerEvent(
            id: id,
            title: input.title,
            agenda: input.agenda,
            date: input.date,
            durationInMinutes: input.durationInMinutes,
            pinCode: generateRandomPin(),
            location: input.location,
            feedbackSummary: nil,
            questions: input.questions.map {
                .init(
                    id: UUID(),
                    questionText: $0.questionText,
                    feedbackType: $0.feedbackType,
                    feedback: nil,
                    feedbackSummary: nil,
                    newFeedbackForQuestion: 0
                )
            },
            newFeedbackForEvent: 0,
            ownerInfo: ownerInfo
        )
        mutableManagerData.managerEvents.append(managerEvent)
        self.userType = .manager(managerData: mutableManagerData, accountInfo: accountInfo)
    }
    
    mutating func appendParticipantEvent(_ pinCode: String) {
        let participantEvent = ParticipantEvent(
            id: UUID(),
            title: generateFeedbackEventTitle(),
            agenda: generateAgenda(),
            date: generateRandomDate(),
            pinCode: generateRandomPin(),
            location: generateRandomLocation(),
            durationInMinutes: generateRandomDurationInMinutes(),
            questions: generateRandomQuestions(),
            feedbackSubmitted: false,
            ownerInfo: .mock()
        )
            
        self.participantEvents.append(participantEvent)
    }
}
