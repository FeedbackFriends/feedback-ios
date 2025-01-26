import ComposableArchitecture
import UIKit

@DependencyClient
public struct SystemClient {
    public var setUserInterfaceStyle: @Sendable (UIUserInterfaceStyle) async -> Void
    public var hideKeyboard: @Sendable () async -> Void
    public var openSettingsURLString: @Sendable () async -> String = { "" }
    public var makeImpact: (_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> Void
}

public extension DependencyValues {
    var systemClient: SystemClient {
        get { self[SystemClient.self] }
        set { self[SystemClient.self] = newValue }
    }
}

extension SystemClient: TestDependencyKey {
    public static var previewValue = SystemClient.noop
    public static let testValue = Self()
}

extension SystemClient {
    static let noop = Self.init(
        setUserInterfaceStyle: { _ in },
        hideKeyboard: {}, 
        openSettingsURLString: { "" },
        makeImpact: { _ in }
    )
}

public extension SystemClient {
    static let live = Self.init(
        setUserInterfaceStyle: { userInterfaceStyle in
            await MainActor.run {
                guard let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene
                else { return }
                scene.keyWindow?.overrideUserInterfaceStyle = userInterfaceStyle
            }
        }, hideKeyboard: {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }, 
        openSettingsURLString: { UIApplication.openSettingsURLString },
        makeImpact: { style in
            let impactMed = UIImpactFeedbackGenerator(style: style)
            impactMed.impactOccurred()
        }
    )
}
