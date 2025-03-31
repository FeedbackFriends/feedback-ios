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
                .onAppear {
                #if DEBUG
print("******** er DEBUG")
                    #else
                    print("******** er IKKE DEBUG")
                    #endif
                }
        }
    }
}
