import LoggedInFeature
import ComposableArchitecture
import SwiftUI
import DesignSystem


public struct AppCoreView: View {
    
    @Bindable var store: StoreOf<AppCore>
    
    public init(store: StoreOf<AppCore>) {
        self.store = store
    }
    
    public var body: some View {
        Group {
            switch(store.destination) {
            case .isLoading:
                loadingView
                
            case .signUp:
                signUpView
                
            case let .error(errorType):
                errorView(errorType)
                
            case .loggedIn:
                tabbarView
            }
        }
        .onAppear { store.send(.onAppear) }
        .onOpenURL { incomingURL in
            store.send(.onOpenURL(incomingURL))
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
            ErrorView(message: "Something went wrong", isLoading: $store.isLoading) {
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
