import ComposableArchitecture
import AdminApp
import SwiftUI

@main
struct Admin: App {
    
    var body: some Scene {
        WindowGroup {
            AdminAppView(
                store: .init(
                    initialState: .init(),
                    reducer: {
                        AdminApp()
                    }
                )
            )
        }
    }
}
