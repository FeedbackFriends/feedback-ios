import Foundation
import Helpers

actor SessionCache {
    private var session: Session?
    private var sessionContinuation: AsyncStream<Session>.Continuation?
    private var shouldMarkEventAsSeen = false
    
    func getSession() -> Session? {
        return session
    }
    
    func updateSession(_ newSession: Session) {
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
    
    func updateOrAppendManagerEvent(_ managerEvent: ManagerEvent) {
        session?.updateOrAppendManagerEvent(managerEvent)
        if let updatedSession = session {
            sessionContinuation?.yield(updatedSession)
        }
    }
    
    func sessionChangedListener() -> AsyncStream<Session> {
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
        session?.updateActivity(activity)
        if let updatedSession = session {
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
