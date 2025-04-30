import ComposableArchitecture
import SwiftUI

struct ScreenBView: View {
    let store: StoreOf<ScreenB>
    
    var body: some View {
        VStack {
            Text("Screen b")
        }
    }
}
