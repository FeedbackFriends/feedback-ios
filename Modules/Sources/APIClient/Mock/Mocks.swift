import Foundation

//#if !RELEASE

let mockAgenda =
    """
    1. Opening Remarks (5 minutes)
    2. Team Member Updates (15 minutes)
        - Progress since last meeting
        - Roadblocks and challenges
    3. Review of Action Items (10 minutes)
        - Updates on assigned tasks
    """

func generateAgenda() -> String? {
    // 30% chance the agenda is nil
    if Bool.random() && Bool.random() {
        return nil
    }
    
    // Generate a random agenda
    let agendaItems = [
        ("Opening Remarks", 5),
        ("Team Member Updates", 15),
        ("Review of Action Items", 10),
        ("Project Updates", 20),
        ("Brainstorming Session", 25),
        ("Problem-Solving Workshop", 15),
        ("Closing Remarks", 5)
    ]
    
    let numberOfItems = Int.random(in: 2...5) // Random number of agenda items
    let selectedItems = agendaItems.shuffled().prefix(numberOfItems)
    
    var agenda = ""
    for (index, item) in selectedItems.enumerated() {
        agenda += "\(index + 1). \(item.0) (\(item.1) minutes)\n"
    }
    
    return agenda.trimmingCharacters(in: .whitespacesAndNewlines)
}

func generateRandomDurationInMinutes() -> Int {
    Int.random(in: 0...2400)
}

func generateRandomQuestions() -> [ParticipantQuestion] {
    [
        .init(
            id: UUID(),
            questionText: "How do you feel about the meeting duration?",
            feedbackType: .emoji
        ),
        .init(
            id: UUID(),
            questionText: "Was the meeting agenda clear and well-organized?",
            feedbackType: .emoji
        ),
        .init(
            id: UUID(),
            questionText: "Did you have enough opportunities to voice your opinions?",
            feedbackType: .emoji
        ),
        .init(
            id: UUID(),
            questionText: "How satisfied are you with the outcomes of the meeting?",
            feedbackType: .emoji
        )
    ]
}

public extension FeedbackSession {
    static let mock = Self(
        title: generateFeedbackEventTitle(),
        agenda: generateAgenda(),
        questions: generateRandomQuestions(),
        ownerInfo: .init(
            name: "Nicolai",
            email: "nicolaidam@gmail.com",
            phoneNumber: "27639523"
        ),
        pinCode: "1234",
        date: Date()
    )
}

public extension Session {
    static func mock(numberOfManagerEvents: Int = 99) -> Self {
        Session(
            participantEvents: .init(uniqueElements: (0...100).map { _ in .mock() }),
            userType: .manager(
                managerData: .init(
                    managerEvents: .init(
                        uniqueElements: generateMockManagerEvents(count: numberOfManagerEvents)
                    )
                ),
                accountInfo: .init(name: "Nicolai", email: "Nicolai@letsgrow.dk", phoneNumber: "88888888")
            )
        )
    }
        
}

private func generateMockManagerEvents(count: Int) -> [ManagerEvent] {
    (0..<count).map { index in
        ManagerEvent.mock(Int.random(in: 0...10), Int.random(in: 0...10))
    }
}

public extension ParticipantEvent {
    static func mock() -> Self {
        ParticipantEvent(
            id: UUID(),
            title: generateFeedbackEventTitle(),
            agenda: generateAgenda(),
            date: .init(timeIntervalSince1970: 0),
            pinCode: generateRandomPin(),
            location: generateRandomLocation(),
            durationInMinutes: generateRandomDurationInMinutes(),
            questions: [
                ParticipantQuestion.init(
                    id: UUID(),
                    questionText: "How do you feel about the meeting duration?",
                    feedbackType: .emoji
                )
            ],
            feedbackSubmitted: Bool.random(),
            ownerInfo: .mock()
        )
    }
}

public extension OwnerInfo {
    static func mock() -> Self {
        OwnerInfo(
            name: "Nicolai",
            email: "Nicolai@letsgrow.dk",
            phoneNumber: "88888888"
        )
    }
}

public extension ManagerEvent {
    static func mock(_ feedbackCount: Int = 30, _ questionsCount: Int = 5) -> Self {
        // Generate questions with feedback
        var questions: [ManagerQuestion] = [.init(
            id: UUID(),
            questionText: "What do you think about the meeting duration?",
            feedbackType: .emoji,
            feedback: nil,
            feedbackSummary: nil,
            newFeedbackForQuestion: 0
        )]
        var totalFeedback = 0

        for _ in 0..<questionsCount {
            let feedbackForQuestion = Int.random(in: 0...30)
            totalFeedback += feedbackForQuestion
            questions.append(generateQuestion(amount: feedbackForQuestion))
        }

        var feedbackSummary: FeedbackSummary?
        if totalFeedback != 0 {
            feedbackSummary = generateFeedbackSummary(total: totalFeedback)
        }

        return Self.init(
            id: UUID(),
            title: generateFeedbackEventTitle(),
            agenda: generateAgenda(),
            date: generateRandomDate(),
            durationInMinutes: Int.random(in: 0...2400),
            pinCode: generateRandomPin(),
            location: generateRandomLocation(),
            feedbackSummary: feedbackSummary,
            questions: questions,
            newFeedbackForEvent: Int.random(in: 1...3),
            ownerInfo: .mock()
        )
    }
}

func generateRandomDate() -> Date {
    let today = Date()
    let daysOffset = Int.random(in: -365...365) // Range: -365 days to +365 days (1 year before to 1 year after)
    let randomDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: today)
    return randomDate ?? today
}

func generateRandomLocation() -> String {
    let possibleLocations = [
        "Roskilde",
        "Copenhagen",
        "Aarhus",
        "Odense",
        "Stockholm",
        "Oslo",
        "Helsinki",
        "Berlin",
        "Amsterdam",
        "Paris",
        "London",
        "New York",
        "San Francisco",
        "Tokyo",
        "Sydney",
        "Barcelona",
        "Munich",
        "Dublin",
        "Toronto",
        "Singapore"
    ]
    
    return possibleLocations.randomElement() ?? "Unknown Location"
}

func generateRandomPin() -> String {
    let pin = Int.random(in: 1000...9999)
    return String(pin)
}

func generateFeedbackEventTitle() -> String {
    let possibleTitles = [
        "Standup Meeting",
        "Team Retrospective",
        "Project Kickoff",
        "Weekly Sync-Up",
        "Brainstorming Session",
        "Quarterly Planning",
        "All-Hands Meeting",
        "Leadership Roundtable",
        "Product Demo Day",
        "Design Review",
        "Code Review Session",
        "Customer Feedback Workshop",
        "Stakeholder Alignment Meeting",
        "Sprint Planning",
        "Daily Standup",
        "Town Hall Meeting",
        "End-of-Year Review",
        "Problem-Solving Workshop",
        "Company Update",
        "Strategy Session"
    ]
    
    return possibleTitles.randomElement() ?? "Meeting"
}

private func generateFeedbackSummary(total: Int) -> FeedbackSummary {
    // Generate random weights ensuring percentages sum to 100
    let verySadWeight = Int.random(in: 0...50)
    let sadWeight = Int.random(in: 0...(100 - verySadWeight))
    let happyWeight = Int.random(in: 0...(100 - verySadWeight - sadWeight))
    let veryHappyWeight = 100 - (verySadWeight + sadWeight + happyWeight)

    // Convert weights to percentages
    let verySadPercentage = Double(verySadWeight)
    let sadPercentage = Double(sadWeight)
    let happyPercentage = Double(happyWeight)
    let veryHappyPercentage = Double(veryHappyWeight)

    return FeedbackSummary(
        totalFeedback: total,
        verySadPercentage: verySadPercentage,
        sadPercentage: sadPercentage,
        happyPercentage: happyPercentage,
        veryHappyPercentage: veryHappyPercentage
    )
}

public extension ManagerEvent {
    static let mockEmpty = Self.init(
        id: UUID(),
        title: "Standup Meeting",
        agenda: mockAgenda,
        date: .init(timeIntervalSince1970: 0),
        durationInMinutes: 30,
        pinCode: "1234",
        location: "Roskilde",
        feedbackSummary: nil,
        questions: [.init(
            id: UUID(),
            questionText: "What do you think about this aspect of the experience?",
            feedbackType: .emoji,
            feedback: nil,
            feedbackSummary: nil,
            newFeedbackForQuestion: 0
        )],
        newFeedbackForEvent: 2,
        ownerInfo: .mock()
    )
}

public func generateQuestion(amount: Int) -> ManagerQuestion {
    let feedback = generateFeedback(amount: amount)
    
    let feedbackSummary: QuestionFeedbackSummary? = amount > 0 ? generateFeedbackSummary(total: amount) : nil
    
    return ManagerQuestion(
        id: UUID(),
        questionText: "How do you feel about this aspect of the experience?",
        feedbackType: .emoji,
        feedback: feedback,
        feedbackSummary: feedbackSummary,
        newFeedbackForQuestion: Int.random(in: 0...4)
    )
}

private func generateFeedbackSummary(total: Int) -> QuestionFeedbackSummary {
    let verySadCount = Int.random(in: 0...total / 2)
    let sadCount = Int.random(in: 0...(total - verySadCount) / 3)
    let happyCount = Int.random(in: 0...(total - verySadCount - sadCount) / 2)
    let veryHappyCount = total - (verySadCount + sadCount + happyCount)
    
    return QuestionFeedbackSummary(
        totalFeedback: total,
        verySadCount: verySadCount,
        sadCount: sadCount,
        happyCount: happyCount,
        veryHappyCount: veryHappyCount
    )
}

public func generateFeedback(amount: Int) -> [Feedback] {
    let possibleEmojis: [Emoji] = [.veryHappy, .happy, .sad, .verySad]
    let possibleComments = [
        "Wow it was amazing",
        "Absolutely fantastic!",
        "Quite good, had a great time.",
        "Could have been better.",
        "Really disappointing.",
        nil // Represents no comment
    ]
    
    var feedbackArray: [Feedback] = []
    
    for _ in 0..<amount {
        let randomEmoji = possibleEmojis.randomElement()!
        let randomComment = possibleComments.randomElement()!
        let feedback = Feedback(type: .emoji(emoji: randomEmoji, comment: randomComment), questionId: UUID(), isNew: Bool.random()) 
        feedbackArray.append(feedback)
    }
    
    return feedbackArray
}

//
//public extension Event {
//    static let mock = Self(
//        id: UUID().uuidString,
//        title: "Hello",
//        agenda: mockAgenda,
//        date: Date(),
//        durationInMinutes: 30,
//        location: "Copenhagen",
//        createdAt: Date()
//    )
//}
//
////#endif
