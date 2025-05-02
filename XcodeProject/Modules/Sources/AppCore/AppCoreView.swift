import Tabbar
import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct AppCoreView: View {
    
    @Bindable var store: StoreOf<AppCore>
    
    public init(store: StoreOf<AppCore>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            switch(store.destination) {
                
            case .isLoading:
                LoadingView()
                
            case .signUp:
                signUpView
                
            case let .error(errorType):
                errorView(errorType)
                
            case .loggedIn:
                loggedInView
            }
        }
        .animation(.linear(duration: 0.8), value: store.destination)
        .onOpenURL { incomingURL in
            store.send(.onOpenURL(incomingURL))
        }
    }
    
    @ViewBuilder
    private var signUpView: some View {
        if let store = store.scope(state: \.destination.signUp, action: \.destination.signUp) {
            SignUpView(store: store)
                .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var loggedInView: some View {
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

struct LoadingView: View {
    @State var didLoad: Bool = false
    var body: some View {
        VStack {
            if didLoad {
                LottieView(lottieFile: .loading, loopMode: true)
                    .frame(width: 400, height: 50)
                Text("Loading data")
                    .padding(.top, 20)
                    .font(.montserratRegular, 16)
                    .foregroundStyle(Color.themeDarkGray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.themeBackground.ignoresSafeArea())
        .onAppear {
            didLoad = true
        }
        .animation(.linear(duration: 0.3), value: didLoad)
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
