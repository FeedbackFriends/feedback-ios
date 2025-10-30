import ComposableArchitecture
import Foundation

@DependencyClient
public struct SystemClient: Sendable {
    public var openAppSettings: @Sendable () async -> String = { "" }
    @DependencyEndpoint
    public var openEmail: @Sendable (_ subject: String, _ body: String) -> URL = { _, _ in URL(string: "")! }
    public var configuration: @Sendable () -> AppConfiguration = {
        AppConfiguration(webBaseUrl: URL(string: "")!, appStoreId: "", supportEmail: "")
    }
}
