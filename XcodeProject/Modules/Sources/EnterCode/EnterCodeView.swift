import Model
import DesignSystem
import SwiftUI
import ComposableArchitecture

public struct EnterCodeView: View {
    
    @FocusState var enterCodeTextfieldFocused: Bool
    @Bindable var store: StoreOf<EnterCode>
    
    public init(store: StoreOf<EnterCode>) {
        self.store = store
    }
    
    public var body: some View {
        content
            .onTapGesture { store.send(.backgroundTap) }
            .background(Color.themeBackground.ignoresSafeArea())
    }
}

private extension EnterCodeView {
    
    var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                ZStack {
                    VStack(alignment: .center) {
                        Text("Let's give some")
                            .font(.montserratBold, 18)
                            .padding(.top, 40)
                        Text("Feedback")
                            .font(.montserratBlack, 50)
                            .padding(.top, 4)
                        Text("Enter PIN Code")
                            .font(.montserratBold, 20)
                            .padding(.top, 70)
                            .foregroundStyle(Color.themeDarkGray)
                        TextField("", text: $store.pinCodeInput.value)
                            .font(.montserratBold, 16)
                            .padding()
                            .foregroundColor(Color.themeDarkGray)
                            .background(Color.themeDarkGray.opacity(0.15).gradient)
                            .clipShape(Capsule(style: .continuous))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .submitLabel(.next)
                            .focused($enterCodeTextfieldFocused)
                            .pinCodeInputValidation(pinCodeInput: $store.pinCodeInput)
                        Button("Start feedback") {
                            store.send(.startFeedbackButtonTap)
                        }
                        .disabled(store.disableStartFeedbackButton)
                        .isLoading(store.startFeedbackPincodeInFlight)
                        .buttonStyle(LargeButtonStyle())
                        .padding(.top, 12)
                        Spacer()
                    }
                    .synchronize($store.enterCodeTextfieldFocused, $enterCodeTextfieldFocused)
                    .padding(.all, Theme.padding)
                    .padding(.top, 30)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(Color.themeDarkGray.gradient)
                }
            }
        }
    }
    
}

#Preview {
    EnterCodeView(
        store: .init(
            initialState: .init(),
            reducer: {
                EnterCode()
            }
        )
    )
}
