import AppCore
import ComposableArchitecture
import SwiftUI
import DesignSystem

@main
struct FeedbackApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppCoreView(store: appDelegate.intialStore)
                .onOpenURL { url in
                    guard let deeplink = DeeplinkParser.fromUrl(url) else { return }
                    appDelegate.intialStore.send(.onUrlOpen(deeplink))
                }
                #if DEBUG
                .overlay(alignment: .trailing) {
                    DebugMenuView()
                }
                #endif
        }
    }
}
