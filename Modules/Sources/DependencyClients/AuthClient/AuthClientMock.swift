import Foundation

private var cont: AsyncStream<UserState>.Continuation!

public extension AuthClient {
    static let mock = Self.init(
        setupStateListener: {},
        signInAnonymously: {
            cont?.yield(.anonymous)
        },
        fetchCustomRole: { nil },
        googleLogin: {
            cont?.yield(.authenticated)
        },
        appleLogin: {
            cont?.yield(.authenticated)
        },
        logout: {
            cont?.yield(.loggedOut)
        },
        userStateChanged: {
            AsyncStream { continuation in
                cont = continuation
            }
        }
    )
}
