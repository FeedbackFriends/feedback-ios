import Model

actor UpdatedSessionManager {
    private var lastUpdatedSession: UpdatedSession?
    
    func updateSession(newSession: UpdatedSession) -> UpdatedSession? {
        if lastUpdatedSession == newSession {
            return nil
        } else {
            lastUpdatedSession = newSession
            return newSession
        }
    }
}
