#if DEBUG
import ComposableArchitecture
import SwiftUI
import Model
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseMessaging
import TabbarFeature
import DesignSystem

struct DebugMenuView: View {
	@State var debugMenuExpanded: Bool = false
	@State var hideDebugMenu: Bool = false
	var apiClient: APIClient {
		@Dependency(\.apiClient) var apiClient
		return apiClient
	}
	var notificationClient: NotificationClient {
		@Dependency(\.notificationClient) var notificationClient
		return notificationClient
	}
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
								print(token ?? "Not found")
							}
						}
						Button("Print fcm token") {
							Task {
								print(Messaging.messaging().fcmToken ?? "Not found")
							}
						}
						Button("Local mock notification") {
							Task {
								notificationClient.scheduleLocalNotification(
									title: "mock title",
									body: "mock body",
									userInfo: [:],
									presentAfterDelayInSeconds: 5,
									id: "mock_notification"
								)
							}
						}
						Button("Crash") {
							fatalError("Debug crash")
						}
						Button("Logout") {
							Task {
								try Auth.auth().signOut()
							}
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
			.foregroundStyle(Color.themeText)
		}
	}
}
#endif
