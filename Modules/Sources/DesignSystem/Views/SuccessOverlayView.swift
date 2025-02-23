import SwiftUI

public extension View {
    /// Success overlay animation shown before navigation
    /// - Parameter message: Message displayed on success overlay
    /// - Parameter delay: Delay time before navigationCallback is triggered, default value is 2.5 seconds
    /// - Parameter show: Decides when overlay should be shown
    /// - Parameter enableAutomaticDismissal: If automatic dismissal should be enabled after given delay
    func successOverlay(
        message: String,
        delay: Double = 1.8,
        show: Binding<Bool>,
        enableAutomaticDismissal: Bool = true
    ) -> some View {
        modifier(
            SuccessOverlayViewModifier(
                show: show,
                animationDelay: delay,
                message: message,
                enableAutomaticDismissal: enableAutomaticDismissal
            )
        )
    }
}


struct SuccessOverlayViewModifier: ViewModifier {
    
    @Binding var show: Bool
    let animationDelay: Double
    let message: String
    let enableAutomaticDismissal: Bool
    @Environment(\.dismiss) var dismiss
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                SuccessOverlayView(message: message)
                    .zIndex(999)
                    .onAppear {
                        Task { @MainActor in
                            if enableAutomaticDismissal {
                            try await Task.sleep(for: .seconds(animationDelay))
                                dismiss()
                            }
                        }
                    }
            }
        }
        .animation(.linear(duration: 0.5), value: show)
    }
}


struct SuccessOverlayView: View {
    
    let message: String
    @State private var showAlert = false
    @State private var alertDidAppear = false
    @State private var isModal = true
    @AccessibilityFocusState private var isFocused: Bool
//    @Dependency(\.hapticsClient) var hapticsClient
    
    public var body: some View {
        content
            .onDisappear(perform: {
                self.isFocused = false
                self.isModal = false
            })
            .onChange(of: showAlert, { oldValue, newValue in
                if showAlert {
                    //A delay is needed here to get the accessibility focus working
                    Task { @MainActor in
                        try await Task.sleep(for: .seconds(0.2))
                        self.isFocused = true
                    }
                }
            })
    }
}

private extension SuccessOverlayView {
    
    var content: some View {
        ZStack {
//            Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity).background(Material.ultraThinMaterial)
            backgroundView
                .onAppear {
                    Task { @MainActor in
                        try await Task.sleep(for: .seconds(0.5))
                        withAnimation {
                            self.showAlert = true
                        }
                    }
                }
            if showAlert {
                alertView
                    // Fix so voiceover stays on the "message" while success overlay is shown
                    .if(self.isModal) {
                        $0.accessibility(addTraits: .isModal)
                    }
                    .onAppear {
                        Task { @MainActor in
                            try await Task.sleep(for: .seconds(0.2))
                                withAnimation(.spring(response: 0.7, dampingFraction: 0.925, blendDuration: 10)) {
                                    alertDidAppear = true
                                }
                            try await Task.sleep(for: .seconds(0.6))
                            #warning("lav haptic")
//                            hapticsClient.makeImpact(.soft)
                        }
                    }
                    .sensoryFeedback(.success, trigger: alertDidAppear)
                    .transition(.opacity)
                    .padding(50)
                    .background(Color.themeBackground)
                    .cornerRadius(16)
            }
        }
    }
    
    var backgroundView: some View {
        Color.black
            .opacity(0.05)
            .ignoresSafeArea()
//        Material.ultraThin.secondary
//        Color.white.opacity(0.6).ignoresSafeArea()
    }
    
    var alertView: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .foregroundColor(Color.themeGreen)
                .frame(width: 40, height: 40)
                .scaleEffect(alertDidAppear ? 1 : 0)
            Text(message)
                .font(.montserratBold, 18)
                .foregroundColor(Color.themeDarkGray)
                .multilineTextAlignment(.center)
                .accessibilityFocused($isFocused)
        }
    }
}

private struct SuccessOverlayPreviewHelper: View {
    @State var show = false
    var body: some View {
        Button("Test overlay") {
            self.show = true
        }
        .successOverlay(
            message: "Test banner",
            show: $show
        ) 
    }
}

struct SuccessOverlay_Previews: PreviewProvider {
    static var previews: some View {
        SuccessOverlayPreviewHelper()
    }
}
