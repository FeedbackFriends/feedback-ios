import Foundation
import Helpers

actor SessionCache {
    private var session: NewSession?
    private var sessionContinuation: AsyncStream<NewSession>.Continuation?
    private var shouldMarkEventAsSeen: Bool
    
    init(
        session: NewSession? = nil,
        sessionContinuation: AsyncStream<NewSession>.Continuation? = nil,
        shouldMarkEventAsSeen: Bool = false
    ) {
        self.session = session
        self.sessionContinuation = sessionContinuation
        self.shouldMarkEventAsSeen = shouldMarkEventAsSeen
    }
    
    func getSession() -> NewSession? {
        return session
    }
    
    func updateSession(_ newSession: NewSession) {
        if newSession != session {
            sessionContinuation?.yield(newSession)
            session = newSession
        }
    }
    
    func deleteEvent(_ eventId: UUID) {
        session?.deleteEvent(eventId)
        if let updatedSession = session {
            sessionContinuation?.yield(updatedSession)
        }
    }
    
    func updateOrAppendManagerEvent(event: ManagerEvent, recentlyUsedQuestions: Set<RecentlyUsedQuestions>? = nil) {
        session?.updateOrAppendManagerEvent(event)
        if let recentlyUsedQuestions {
            session?.updateRecentlyUsedQuestions(recentlyUsedQuestions)
        }
        if let updatedSession = session {
            sessionContinuation?.yield(updatedSession)
        }
    }
    
    func sessionChangedListener() -> AsyncStream<NewSession> {
        AsyncStream { continuation in
            self.sessionContinuation = continuation
        }
    }
    
    func updateOrAppendParticipantEvent(_ event: ParticipantEvent) {
        session?.updateOrAppendParticipantEvent(event)
        if let updatedSession = session {
            sessionContinuation?.yield(updatedSession)
        }
    }
    
    func updateAccount(name: String?, email: String?, phoneNumber: String?) {
        session?.updateAccount(name: name, email: email, phoneNumber: phoneNumber)
        if let updatedSession = session {
            sessionContinuation?.yield(updatedSession)
        }
    }
    
    func markEventAsSeen(eventId: UUID) {
        session?.markEventAsSeen(eventId: eventId)
        if let updatedSession = session {
            sessionContinuation?.yield(updatedSession)
        }
    }
    
    func updateActivity(_ activity: Activity) {
        let existingActivity = self.session?.activity
        session?.updateActivity(activity)
        if let updatedSession = session, existingActivity != activity {
            sessionContinuation?.yield(updatedSession)
        }
    }
    
    func markActivityAsSeen() {
        session?.markActivityAsSeen()
        if let updatedSession = session {
            sessionContinuation?.yield(updatedSession)
        }
    }
    
    func reset() {
        self.session = nil
    }
}
