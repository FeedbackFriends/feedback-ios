import Foundation
import Helpers

final class SessionCache {
    private var session: Session?
    private var sessionContinuation: AsyncStream<Session>.Continuation?
    
    func getSession() -> Session? {
        return session
    }
    
    func updateSession(_ newSession: Session) {
        session = newSession
        sessionContinuation?.yield(newSession)
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
    
    func updateOrAppendAttendingEvent(_ event: ParticipantEvent) {
        session?.updateOrAppendAttendingEvent(event)
        if let updatedSession = session {
            sessionContinuation?.yield(updatedSession)
        }
    }
}
