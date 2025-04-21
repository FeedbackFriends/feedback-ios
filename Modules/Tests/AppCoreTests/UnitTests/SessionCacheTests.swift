//@testable import LiveClients
//import Testing
//import Helpers
//import Foundation
//
//@MainActor
//struct SessionCacheTests {
//    
//    
//    @Test
//    func testUpdateSession() async {
//        var sessionCache: SessionCache = SessionCache()
//        let session: NewSession = .mockAnonymous()
//        await sessionCache.updateSession(session)
//        #expect(await sessionCache.getSession() == session, "Session should be updated correctly.")
//    }
//    
//    @Test
//    func sessionCache_DeleteEvent() async {
//        var sessionCache: SessionCache = SessionCache.init()
//        let eventId = UUID()
//        await sessionCache.updateSession(newSession)
//        await sessionCache.deleteEvent(eventId)
//        let session = await sessionCache.getSession()
//        #expect(session?.managerData?.managerEvents.contains(where: { $0.id == eventId }) == false, "Event should be deleted.")
//    }
//    
//    @Test
//    func sessionCache_UpdateManagerEvent() async {
//        let managerEvent = ManagerEvent.mock()
//        await sessionCache.updateOrAppendManagerEvent(event: managerEvent)
//        let session = await sessionCache.getSession()
//        #expect(session?.managerData?.managerEvents.contains(managerEvent) == true, "Manager event should be updated.")
//    }
//    
//    @Test
//    func sessionCache_UpdateRecentlyUsedQuestions() async {
//        let recentlyUsedQuestions: Set<RecentlyUsedQuestions> = [
//            .init(
//                questionText: "Hellow good world",
//                feedbackType: .emoji,
//                updatedAt: Date.distantPast
//            )
//        ]
//        await sessionCache.updateOrAppendManagerEvent(
//            event: .mockEmpty,
//            recentlyUsedQuestions: recentlyUsedQuestions
//        )
//        let session = await sessionCache.getSession()
//        #expect(session?.recentlyUsedQuestions() == recentlyUsedQuestions, "Recently used questions should be updated.")
//    }
//    
//    @Test
//    func sessionCache_UpdateParticipantEvent() async {
//        let participantEvent = ParticipantEvent.mock()
//        await sessionCache.updateOrAppendParticipantEvent(participantEvent)
//        let session = await sessionCache.getSession()
//        #expect(session?.participantEvents.contains(participantEvent) == true, "Participant event should be updated.")
//    }
//    
//    @Test
//    func sessionCache_UpdateAccount() async {
//        let name = "John Doe"
//        let email = "john.doe@example.com"
//        let phoneNumber = "1234567890"
//        await sessionCache.updateAccount(name: name, email: email, phoneNumber: phoneNumber)
//        let session = await sessionCache.getSession()
//        #expect(session?.accountInfo?.name == name, "Account name should be updated.")
//        #expect(session?.accountInfo?.email == email, "Account email should be updated.")
//        #expect(session?.accountInfo?.phoneNumber == phoneNumber, "Account phone number should be updated.")
//    }
//    
//    @Test
//    func testMarkEventAsSeen() async {
//        // Arrange
//        guard let eventId = newSession.managerData?.managerEvents.keys.first else {
//            XCTFail("No event ID found in manager data")
//            return
//        }
//        
//        // Act: Call markEventAsSeen
//        await sessionCache.markEventAsSeen(eventId: eventId)
//        
//        // Assert: Ensure event-level feedback was updated
//        let session = await sessionCache.getSession()
//        if let updatedEvent = session?.managerData?.managerEvents[eventId] {
//            #expect(updatedEvent.feedbackSummary?.unseenCount == 0, "Event-level feedback should be updated.")
//        }
//        
//        // Assert: Ensure question-level feedback was updated
//        if let updatedEvent = session?.managerData?.managerEvents[eventId] {
//            for question in updatedEvent.questions {
//                #expect(question.feedbackSummary?.unseenCount == 0, "Question-level feedback should be updated.")
//                for feedback in question.feedback {
//                    #expect(feedback.seenByManager == true, "Feedback should be marked as seen.")
//                }
//            }
//        }
//        
//        // Assert: Ensure activity-level feedback was updated
//        if let updatedActivity = session?.activity {
//            #expect(updatedActivity.unseenTotal == 0, "Activity-level feedback should be updated.")
//            for item in updatedActivity.items {
//                #expect(item.seenByManager == true, "Activity items should be marked as seen.")
//            }
//        }
//    }
//    
//    @Test
//    func sessionCache_UpdateActivity() async {
//        let activity = Activity.init(
//            items: [.init(
//                id: UUID(),
//                date: Date(),
//                eventTitle: "Hello world",
//                eventId: UUID(),
//                newFeedbackCount: 3,
//                seenByManager: false
//            )],
//            unseenTotal: 19
//        )
//        await sessionCache.updateActivity(activity)
//        let session = await sessionCache.getSession()
//        #expect(session?.activity == activity, "Activity should be updated.")
//    }
//    
//    @Test
//    func sessionCache_MarkActivityAsSeen() async {
//        await sessionCache.markActivityAsSeen()
//        let session = await sessionCache.getSession()
//        #expect(session?.activity?.unseenTotal == 0, "Activity should be marked as seen.")
//    }
//    
//    @Test
//    func sessionCache_ResetSession() async {
//        await sessionCache.updateSession(newSession)
//        await sessionCache.reset()
//        let session = await sessionCache.getSession()
//        #expect(session == nil, "Session should be reset to nil.")
//    }
//
//}
//
