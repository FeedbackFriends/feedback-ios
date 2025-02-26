import ComposableArchitecture
import SwiftUI
import Helpers
import FirebaseAuth
import LoggedInFeature
import DesignSystem

struct DebugMenuView: View {
    @State var debugMenuExpanded: Bool = false
    @State var hideDebugMenu: Bool = false
    var body: some View {
        if !hideDebugMenu {
            HStack {
                Button {
                    withAnimation {
                        self.debugMenuExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.compact.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding()
                }
                if debugMenuExpanded {
                    VStack {
                        Button("Sign in with Mock") {
                            Task {
                                do {
                                    @Dependency(\.apiClient) var apiClient
                                    let mockToken = try await apiClient.getMockToken()
                                    print("Mock token received: \n \(mockToken)")
                                    try await Auth.auth().signIn(withCustomToken: mockToken)
                                    print("Signed in")
                                    _ = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
                                    print("Succesful signin with mock token")
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        Button("Print id token") {
                            Task {
                                let token = try await Auth.auth().currentUser?.getIDToken()
                                print(token ?? "Token not found")
                            }
                        }
                        Button("Crash") {
                            fatalError("Debug crash")
                        }
                        Button("Hide") {
                            hideDebugMenu = true
                        }
                    }
                    .padding()
                }
            }
            .background(Color.blue)
            .cornerRadius(8)
            .foregroundStyle(Color.white)
        }
    }
}
