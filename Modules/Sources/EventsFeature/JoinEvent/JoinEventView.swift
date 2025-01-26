import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct JoinEventView: View {
    
    @Bindable var store: StoreOf<JoinEvent>
    @FocusState private var isFocused: Bool
    
    public init(store: StoreOf<JoinEvent>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Join event")
                    .font(.montserratBold, 28)
                    .padding(.top, 20)
                Text("Event code")
                    .font(.montserratBold, 18)
                    .foregroundStyle(Color.themeDarkGray)
                TextField("", text: $store.inputCode)
                    .font(.montserratBold, 16)
                    .padding()
                    .foregroundColor(Color.themeDarkGray)
                    .background(Color.themeDarkGray.opacity(0.15).gradient)
                    .clipShape(Capsule())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .submitLabel(.next)
                    .focused($isFocused)
                    .padding(.top, 5)
                    .pinCodeValidation(text: $store.inputCode)
                Button("Join") {
                    hideKeyboard()
                    store.send(.joinButtonTap)
                }
                .buttonStyle(LargeButtonStyle())
                .isLoading(store.joinRequestInFlight)
                .padding(.bottom, 20)
                .disabled(store.disableJoinButton)
            }
            .onAppear { isFocused = true }
            .padding(.all, Theme.padding)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundStyle(Color.themeDarkGray.gradient)
            .background(Color.themeBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SharedCloseButton {
                        store.send(.closeButtonTap)
                    }
                }
            }
            .background {
                /// this makes the keyboard to appear with a single animation
                FirstResponderFieldView()
                                .frame(width: 0, height: 0)
                                .opacity(0)
            }
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .successOverlay(
                message: "Event joined",
                show: $store.showSuccessOverlay
            )
        }
    }
}

#Preview {
    JoinEventView(
        store: .init(
            initialState: .init(),
            reducer: {
                JoinEvent()
            }
        )
    )
}

#Preview {
    @Previewable @State var showDeleteConfirmation: Bool = false
    Button("Join") {
        showDeleteConfirmation = true
    }
    .sheet(isPresented: $showDeleteConfirmation) {
        JoinEventView(
            store: .init(
                initialState: .init(),
                reducer: {
                    JoinEvent()
                }
            )
        )
        .presentationDetents([.medium])
    }
}

class FirstResponderField: UITextField {
    init() {
        super.init(frame: .zero)
        keyboardType = .numberPad
        becomeFirstResponder()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct FirstResponderFieldView: UIViewRepresentable {
    func makeUIView(context: Context) -> FirstResponderField {
        return FirstResponderField()
    }

    func updateUIView(_ uiView: FirstResponderField, context: Context) {}
}
