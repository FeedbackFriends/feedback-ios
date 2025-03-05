import Foundation

actor MockSessionEngine {
    
    var session = Session.mock(numberOfManagerEvents: 99)
    var sessionContinuation: AsyncStream<Session>.Continuation!
    
    func getSession() -> Session {
        return session
    }
    
    func updateManagerEvent(_ input: EventInput, _ id: UUID) {
        session.updateManagerEvent(input, id)
    }
    
    func appendManagerEvent(input: EventInput, id: UUID, ownerInfo: OwnerInfo) {
        session.appendManagerEvent(input: input, id: id, ownerInfo: ownerInfo)
    }
    
    func deleteEvent(_ id: UUID) {
        session.deleteEvent(id)
    }
    
    func appendParticipantEvent(_ pinCode: String) {
        session.appendParticipantEvent(pinCode)
    }
    
    func stream() -> AsyncStream<Session> {
        AsyncStream { continuation in
            sessionContinuation = continuation
        }
    }
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
