import ComposableArchitecture
import Foundation
import Model

@DependencyClient
public struct WebURLClient: Sendable {
    @DependencyEndpoint
    public var inviteUrl: @Sendable (_ pinCode: PinCode) throws -> URL
    public var privacyPolicyUrl: @Sendable () throws -> URL
    @DependencyEndpoint
    public var appStoreReviewUrl: @Sendable () throws -> URL
}
