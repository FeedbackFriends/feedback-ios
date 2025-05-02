import SwiftUI
import DesignSystem

struct NotificationPermissionView: View {
        
    let requestAuthorizationButtonTap: () -> Void
    let dismissButtonTap: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                LottieView(lottieFile: .messagePermission)
                    .frame(width: 300, height: 200)
                    Text("Please allow notifications so we can send you important messages.")
                        .padding(.top, 30)
                        .font(.montserratRegular, 14)
                        .padding(.horizontal, 60)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.themeDarkGray)
                Spacer()
                givePermissionButton("Give permission") {
                    requestAuthorizationButtonTap()
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar { toolbarContent }
            .navigationTitle("Messaging")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.themeBackground)
        }
    }
}

private extension NotificationPermissionView {
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Not now") {
                    dismissButtonTap()
                }
                .buttonStyle(SecondaryToolbarButtonStyle())
            }
        }
    }
    
    func givePermissionButton(_ buttonText: String, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.themeGreen)
                Text(buttonText)
                    .font(.montserratBold, 14)
                    .foregroundColor(.themeDarkGray)
                Spacer()
            }
        }
        .buttonStyle(LargeBoxButtonStyle())
    }
}

#Preview {
    NotificationPermissionView(
        requestAuthorizationButtonTap: {},
        dismissButtonTap: {}
    )
}

#Preview {
    @Previewable @State var showSheet: Bool = false
    Button("Show sheet") {
        showSheet = true
    }
    .sheet(isPresented: $showSheet) {
        NotificationPermissionView(
            requestAuthorizationButtonTap: {},
            dismissButtonTap: {}
        )
        .presentationDetents([.height(600)])
    }
}


