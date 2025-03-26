import OpenAPIRuntime
import Foundation
import OpenAPIURLSession
import Network
import HTTPTypes
import Logger
import ComposableArchitecture
import FirebaseAuth

struct AuthorisationMiddleware: ClientMiddleware {
    
    func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL)
        async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        @Dependency(\.logClient) var logger
        guard request.needsAuthorization else {
            return try await next(request, body, baseURL)
        }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else {
            logger.log(.error, "Session has expired for good, should only happen if user is deleted or disabled", nil)
            throw URLError(URLError.Code.userAuthenticationRequired)
        }
        var mutableRequest = request
        mutableRequest.headerFields[.authorization] = "Bearer \(idToken)"
        let response = try await next(mutableRequest, body, baseURL)
        if request.forceRefreshAfter {
            _ = try await Auth.auth().currentUser?.getIDToken(forcingRefresh: true)
        }
        return response
    }
}

enum Request {
    /// Indicates whether the request requires authorization
    @TaskLocal static var needsAuthorization: Bool = false
    
    /// Indicates whether the ID token should be refreshed after an API call
    @TaskLocal static var forceRefreshAfter: Bool = false
}

extension HTTPTypes.HTTPRequest {
    
    var needsAuthorization: Bool {
        Request.needsAuthorization
    }
    
    var forceRefreshAfter: Bool {
        Request.forceRefreshAfter
    }
}

/// Executes an authorized API call.
///
/// - Parameters:
///   - forceRefresh: A flag indicating whether the ID token should be refreshed after the call.
///   - task: The task to execute that requires authorization.
/// - Returns: The result of the executed task.
/// - Throws: Rethrows any errors encountered during the execution of the task.
func withAuthorization<T>(
    forceRefreshAfter: Bool = false,
    _ task: @escaping () async throws -> T
) async throws -> T {
    try await Request.$needsAuthorization.withValue(true) {
        try await Request.$forceRefreshAfter.withValue(forceRefreshAfter) {
            try await task()
        }
    }
}
