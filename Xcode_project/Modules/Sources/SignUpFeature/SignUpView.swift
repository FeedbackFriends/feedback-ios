import Foundation
import SwiftUI
import ComposableArchitecture
import DesignSystem
import Model

public struct SignUpView: View {
    
    @Bindable var store: StoreOf<SignUp>
    
    public init(store: StoreOf<SignUp>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                Image.letsGrowIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
                signUpView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.large)
            .background(Color.themeBackground)
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .sheet(
                item: $store.scope(
                    state: \.destination?.selectUserType,
                    action: \.destination.selectUserType
                )
            ) { store in
                SelectUserTypeView(store: store)
                    .interactiveDismissDisabled()
                    .presentationDetents([.height(240)])
            }
        }
    }
}

private extension SignUpView {
    var signUpView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Sign up")
                .font(.montserratBold, 28)
                .foregroundStyle(Color.themeDarkGray.gradient)
            Text("Signup to get started on your feedback jurney.")
                .font(.montserratRegular, 14)
                .foregroundColor(.themeDarkGray)
            Button {
                store.send(.signUpWithAppleButtonTap)
            } label: {
                HStack(spacing: 14) {
                    if store.appleLoginInFlight {
                        ProgressView()
                            .transition(.blurReplace)
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: Color.themeWhite)
                            )
                    }
                    Image.iconApple
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18, height: 18)
                    Text("Continue with Apple")
                    Spacer()
                }
                .padding(.leading, 24)
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.themeWhite.gradient))
            .disabled(store.googleLoginInFlight || store.appleLoginInFlight)
            Button {
                store.send(.signUpWithGoogleButtonTap)
            } label: {
                HStack(spacing: 14) {
                    if store.googleLoginInFlight {
                        ProgressView()
                            .transition(.blurReplace)
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: Color.themeDarkGray)
                            )
                    }
                    Image.iconGoogle
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                    Text("Continue with Google")
                        .foregroundStyle(Color.themeDarkGray)
                    Spacer()
                }
                .padding(.leading, 24)
            }
            .buttonStyle(
                LargeButtonStyle(
					backgroundColor: Color.themeWhite
                )
            )
            .disabled(store.googleLoginInFlight || store.appleLoginInFlight)
            .lightShadow()
            .padding(.bottom, 16)
        }
        .animation(.bouncy, value: store.googleLoginInFlight)
        .animation(.bouncy, value: store.appleLoginInFlight)
        .padding(.all, Theme.padding)
    }
}

#Preview {
    SignUpView(
        store: .init(
            initialState: .init(),
            reducer: {
                SignUp()
            }
        )
    )
}
