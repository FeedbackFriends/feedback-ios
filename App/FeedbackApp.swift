import AppCore
import ComposableArchitecture
import SwiftUI

@main
struct FeedbackApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppCoreView(store: appDelegate.intialStore)
                #if DEBUG
                .overlay(alignment: .trailing) {
                    DebugMenuView()
                }
                #endif
        }
    }
}
