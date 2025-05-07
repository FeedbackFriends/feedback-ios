@testable import Model
import Testing
import ComposableArchitecture
import Foundation
import APIClient

@MainActor
struct SessionCacheTests {
    
    @Test
    func sessionCacheYieldsOnSessionChange() async {
        let initial = Session.mock()
        let updated = Session.mockParticipant()
        
        let cache = SessionCache(session: initial)
        let stream = await cache.sessionChangedListener()
        var streamIterator = stream.makeAsyncIterator()
        
        await cache.updateSession(updated)
        
        let next = await streamIterator.next()
        #expect(next == updated)
    }
    
    @Test
    func sessionCacheDoesNotYieldOnSameSession() async {
        let session = Session.mock()
        let cache = SessionCache(session: session)
        let stream = await cache.sessionChangedListener()
        var iterator = stream.makeAsyncIterator()
        
        await cache.updateSession(session)
        let result = await withTimeout(seconds: 0.2) { await iterator.next() }
        
        #expect(result == nil)
    }
    
    @Test
    func getSessionReturnsInitialState() async {
        let session = Session.mock()
        let cache = SessionCache(session: session)
        let result = await cache.getSession()
        #expect(result == session)
    }
    
    @Test
    func sessionCacheDeleteEvent() async {
        let eventId = UUID()
        let event = ManagerEvent(
            id: eventId,
            title: "Event",
            agenda: nil,
            date: .now,
            pinCode: PinCode(value: "123456"),
            durationInMinutes: 30,
            location: "Online",
            ownerInfo: .init(name: nil, email: nil, phoneNumber: nil),
            feedbackSummary: nil,
            questions: []
        )
        
        let session = Session(
            participantEvents: [],
            managerData: .init(managerEvents: [event], activity: .init(items: [], unseenTotal: 0), recentlyUsedQuestions: []),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: .manager
        )
        
        let cache = SessionCache(session: session)
        
        let initial = await cache.getSession()
        #expect(initial?.managerData?.managerEvents.count == 1)
        await cache.deleteEvent(eventId)
        let after = await cache.getSession()
        #expect(after?.managerData?.managerEvents.count == 0)
    }
    
    @Test
    func sessionCacheUpdateOrAppendManagerEvent() async {
        let eventId = UUID()
        let originalEvent = ManagerEvent(
            id: eventId,
            title: "Original Title",
            agenda: nil,
            date: .now,
            pinCode: PinCode(value: "123456"),
            durationInMinutes: 30,
            location: "Room 1",
            ownerInfo: .init(name: nil, email: nil, phoneNumber: nil),
            feedbackSummary: nil,
            questions: []
        )
        
        let session = Session(
            participantEvents: [],
            managerData: .init(managerEvents: [originalEvent], activity: .init(items: [], unseenTotal: 0), recentlyUsedQuestions: []),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: .manager
        )
        
        let cache = SessionCache(session: session)
        
        let updatedEvent = ManagerEvent(
            id: eventId,
            title: "Updated Title",
            agenda: "Updated Agenda",
            date: .now,
            pinCode: PinCode(value: "123456"),
            durationInMinutes: 60,
            location: "Room 2",
            ownerInfo: .init(name: "John", email: "john@example.com", phoneNumber: "1234567890"),
            feedbackSummary: nil,
            questions: []
        )
        
        await cache.updateOrAppendManagerEvent(event: updatedEvent)
        
        let updatedSession = await cache.getSession()
        let event = updatedSession?.managerData?.managerEvents.first
        
        #expect(event?.title == "Updated Title")
        #expect(event?.agenda == "Updated Agenda")
        #expect(event?.durationInMinutes == 60)
        #expect(event?.location == "Room 2")
        #expect(event?.ownerInfo.name == "John")
    }
    
    @Test
    func sessionCacheUpdateRecentlyUsedQuestions() async {
        let initialQuestions: Set<RecentlyUsedQuestions> = [
            .init(questionText: "Old question", feedbackType: .emoji, updatedAt: .distantPast)
        ]
        let newQuestions: Set<RecentlyUsedQuestions> = [
            .init(questionText: "New question", feedbackType: .emoji, updatedAt: .now)
        ]
        
        let session = Session(
            participantEvents: [],
            managerData: .init(managerEvents: [], activity: .init(items: [], unseenTotal: 0), recentlyUsedQuestions: initialQuestions),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: .manager
        )
        
        let cache = SessionCache(session: session)
        await cache.updateRecentlyUsedQuestions(recentlyUsedQuestions: newQuestions)
        
        let updatedSession = await cache.getSession()
        #expect(updatedSession?.managerData?.recentlyUsedQuestions == newQuestions)
    }
    
    
    @Test
    func sessionCacheUpdateOrAppendParticipantEvent() async {
        let event = ParticipantEvent(
            id: UUID(),
            title: "Title",
            agenda: nil,
            date: .now,
            pinCode: PinCode(value: "000000"),
            location: nil,
            durationInMinutes: 30,
            questions: [],
            feedbackSubmitted: false,
            ownerInfo: .init(name: "Owner", email: nil, phoneNumber: nil),
            recentlyJoined: false
        )
        
        let session = Session(
            participantEvents: [],
            managerData: nil,
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: .participant
        )
        
        let cache = SessionCache(session: session)
        await cache.updateOrAppendParticipantEvent(event)
        
        let updated = await cache.getSession()
        #expect(updated?.participantEvents.contains(where: { $0.id == event.id }) == true)
    }
    
    @Test
    func sessionCacheUpdateAccount() async {
        let session = Session.mock()
        let cache = SessionCache(session: session)
        
        await cache.updateAccount(name: "Jane", email: "jane@ai.dk", phoneNumber: "42424242")
        let updated = await cache.getSession()
        
        #expect(updated?.accountInfo.name == "Jane")
        #expect(updated?.accountInfo.email == "jane@ai.dk")
        #expect(updated?.accountInfo.phoneNumber == "42424242")
    }
    
    @Test
    func sessionCacheMarkEventAsSeen() async {
        let eventId = UUID()
        let summary = FeedbackSummary(
            segmentationStats: .init(verySadPercentage: 0, sadPercentage: 0, happyPercentage: 0, veryHappyPercentage: 0),
            countStats: .init(verySadCount: 0, sadCount: 0, happyCount: 0, veryHappyCount: 0, commentsCount: 0, uniqueParticipantFeedback: 0),
            unseenCount: 5
        )
        let question = ManagerQuestion(id: UUID(), questionText: "Q", feedbackType: .emoji, feedback: [], feedbackSummary: summary)
        let event = ManagerEvent(
            id: eventId,
            title: "Event",
            agenda: nil,
            date: .now,
            pinCode: PinCode(value: "111111"),
            durationInMinutes: 60,
            location: nil,
            ownerInfo: .init(name: nil, email: nil, phoneNumber: nil),
            feedbackSummary: summary,
            questions: [question]
        )
        let activityItem = ActivityItems(
            id: UUID(),
            date: .now,
            eventTitle: "Event",
            eventId: eventId,
            newFeedbackCount: 1,
            seenByManager: false
        )
        let activity = Activity(items: [activityItem], unseenTotal: 1)
        let managerData = ManagerData(managerEvents: [event], activity: activity, recentlyUsedQuestions: [])
        let session = Session(participantEvents: [], managerData: managerData, accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .manager)
        let cache = SessionCache(session: session)
        
        await cache.markEventAsSeen(eventId: eventId)
        let updated = await cache.getSession()
        
        #expect(updated?.managerData?.managerEvents[id: eventId]?.feedbackSummary?.unseenCount == 0)
        #expect(updated?.managerData?.managerEvents[id: eventId]?.questions.allSatisfy { $0.feedbackSummary?.unseenCount == 0 } == true)
        #expect(updated?.managerData?.activity.unseenTotal == 0)
        #expect(updated?.managerData?.activity.items.allSatisfy { $0.seenByManager } == true)
    }
    
    @Test
    func sessionCacheUpdateActivity() async {
        let eventId = UUID()
        let activityItem = ActivityItems(
            id: UUID(),
            date: .now,
            eventTitle: "Event",
            eventId: eventId,
            newFeedbackCount: 1,
            seenByManager: false
        )
        let activity = Activity(items: [activityItem], unseenTotal: 1)
        let managerData = ManagerData(managerEvents: [], activity: .init(items: [], unseenTotal: 0), recentlyUsedQuestions: [])
        let session = Session(participantEvents: [], managerData: managerData, accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .manager)
        let cache = SessionCache(session: session)
        
        await cache.updateActivity(activity)
        let updated = await cache.getSession()
        
        #expect(updated?.managerData?.activity == activity)
    }
    
    @Test
    func sessionCacheMarkActivityAsSeen() async {
        let eventId = UUID()
        let activityItem = ActivityItems(
            id: UUID(),
            date: .now,
            eventTitle: "Event",
            eventId: eventId,
            newFeedbackCount: 1,
            seenByManager: false
        )
        let unseenActivity = Activity(items: [activityItem], unseenTotal: 1)
        let session = Session(
            participantEvents: [],
            managerData: .init(managerEvents: [], activity: unseenActivity, recentlyUsedQuestions: []),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: .manager
        )
        let cache = SessionCache(session: session)
        
        await cache.markActivityAsSeen()
        let updated = await cache.getSession()
        
        #expect(updated?.managerData?.activity.unseenTotal == 0)
        #expect(updated?.managerData?.activity.items.allSatisfy { $0.seenByManager } == true)
    }
    
    @Test
    func sessionCacheReset() async {
        let session = Session.mock()
        let cache = SessionCache(session: session)
        
        await cache.reset()
        let result = await cache.getSession()
        
        #expect(result == nil)
    }
}


func withTimeout<T>(seconds: TimeInterval, _ operation: @escaping () async -> T?) async -> T? {
    await withTaskGroup(of: T?.self) { group in
        group.addTask {
            await operation()
        }
        group.addTask {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            return nil
        }
        return await group.next() ?? nil
    }
}
