import Foundation

actor MockAuthEngine {
    
    private var continuation: AsyncStream<UserState>.Continuation?
    
    func yield(_ state: UserState) {
        continuation?.yield(state)
    }
    
    func stream() -> AsyncStream<UserState> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }
}

public extension AuthClient {
    static var mock: Self {
        let mockAuthEngine = MockAuthEngine()
        return Self.init(
            setupStateListener: {},
            signInAnonymously: {
                await mockAuthEngine.yield(.anonymous)
            },
            fetchCustomRole: { nil },
            googleLogin: {
                await mockAuthEngine.yield(.authenticated)
            },
            appleLogin: {
                await mockAuthEngine.yield(.authenticated)
            },
            logout: {
                await mockAuthEngine.yield(.loggedOut)
            },
            userStateChanged: {
                await mockAuthEngine.stream()
            }
        )
    }
}
