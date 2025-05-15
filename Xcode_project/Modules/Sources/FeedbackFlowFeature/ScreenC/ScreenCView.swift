import ComposableArchitecture
import SwiftUI

public struct ScreenCView: View {
    let store: StoreOf<ScreenC>
    
    public init(store: StoreOf<ScreenC>) {
        self.store = store
    }
    public var body: some View {
        VStack {
            Text("Screen c")
        }
    }
}
