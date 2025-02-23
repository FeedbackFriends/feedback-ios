import LoggedInFeature
import ComposableArchitecture
import SwiftUI
import DesignSystem
import FirebaseAuth

public struct AppCoreView: View {
    
    @Bindable var store: StoreOf<AppCore>
    @State var debugMenuExpanded: Bool = false
    @State var hideDebugMenu: Bool = false
    
    public init(store: StoreOf<AppCore>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            switch(store.destination) {
            case .isLoading:
                loadingView
            case .signUp:
                signUpView
                
            case let .error(errorType):
                errorView(errorType)
                
            case .loggedIn:
                tabbarView
                    .transition(.move(edge: .bottom))
            }
        }
        .onOpenURL { incomingURL in
            store.send(.onOpenURL(incomingURL))
        }
        .overlay(alignment: .trailing) {
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
                                        try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
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
                .foregroundStyle(Color.white)
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            LottieView(lottieFile: "loading", loopMode: true)
                .frame(width: 400, height: 50)
            Text("Loading data")
                .padding(.top, 20)
                .font(.montserratRegular, 16)
                .foregroundStyle(Color.themeDarkGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.themeBackground.ignoresSafeArea())
    }
    
    @ViewBuilder
    private var signUpView: some View {
        if let store = store.scope(state: \.destination.signUp, action: \.destination.signUp) {
            SignUpView(store: store)
                .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var tabbarView: some View {
        if let store = store.scope(state: \.destination.loggedIn, action: \.destination.loggedIn) {
            TabbarView(store: store)
                .transition(.opacity)
        }
    }
    
    private func errorView(_ errorType: AppCore.ErrorType) -> some View {
        VStack {
            ErrorView(error: errorType.error, isLoading: $store.isLoading) {
                store.send(.tryAgainButtonTap(errorType))
            }
            
            Button("Log out") {
                self.store.send(.onLogoutButtonTap)
            }
            .padding(.bottom, 20)
            .buttonStyle(SecondaryToolbarButtonStyle())
        }
        .background(Color.themeBackground.ignoresSafeArea())
    }
}


#Preview {
    AppCoreView(
        store: .init(
            initialState: .init(),
            reducer: {
                AppCore()
            }
        )
    )
}
