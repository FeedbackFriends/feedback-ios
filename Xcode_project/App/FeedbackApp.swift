import RootFeature
import ComposableArchitecture
import SwiftUI
import DesignSystem
import Logger

@main
struct FeedbackApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    init() {
        #if DEBUG
        Logger.debug("IS DEBUG: true")
        #else
        Logger.debug("IS DEBUG: false")
        #endif
        
    }
    
    var body: some Scene {
        WindowGroup {
            RootFeatureView(store: appDelegate.intialStore)
                .onOpenURL { url in
                    guard let deeplink = DeeplinkParser.fromUrl(url) else { return }
                    appDelegate.intialStore.send(.onUrlOpen(deeplink))
                }
                #if DEBUG
                .overlay(alignment: .trailing) {
                    DebugMenuView(apiClient: appDelegate.apiClient, notificationClient: appDelegate.notificationClient)
                }
                #endif
        }
    }
}
