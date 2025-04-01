import Foundation
import SwiftUI
import ComposableArchitecture
import DesignSystem
import Helpers

public struct SignUpView: View {
    
    @Bindable var store: StoreOf<SignUp>
    
    public init(store: StoreOf<SignUp>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                VStack {
                    Image.signUpIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
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
                .font(.montserratBold, 35)
                .foregroundStyle(Color.themeDarkGray.gradient)
            Text("Signup to get started on your feedback jurney.")
                .font(.montserratRegular, 14)
                .foregroundColor(.themeDarkGray)
            Button {
                store.send(.signUpWithAppleButtonTap)
            } label: {
                HStack(spacing: 14) {
                    Image.iconApple
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18, height: 18)
                    Text("Continue with Apple")
                    Spacer()
                }
                .padding(.leading, 24)
            }
            .buttonStyle(LargeButtonStyle(color: Color.black.gradient))
            Button {
                store.send(.signUpWithGoogleButtonTap)
            } label: {
                HStack(spacing: 14) {
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
            .buttonStyle(LargeButtonStyle(color: Color.white))
            .shadow(color: .black.opacity(0.08), radius: 2)
            .padding(.bottom, 16)
        }
        .padding(.bottom, 40)
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
