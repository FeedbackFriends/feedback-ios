import SwiftUI
import Foundation
import Domain
import MessageUI
import UIKit

// MARK: - ErrorView with “Report issue” built‑in
public struct ErrorView: View {
    
    // MARK: Dependencies
    let error: PresentableError
    let tryAgainButtonTapped: (() -> Void)?
    @Binding var isLoading: Bool
    
    // MARK: UI State
    @State private var viewDidLoad = false
    @State private var showMailComposer = false
    @State private var showShareSheet = false
    @State private var screenshotData: Data?
    @State private var isCapturing = false
    
    @Environment(\.displayScale) private var displayScale
    
    // MARK: – Appearance helpers
    private var exclamationmark: CGFloat { viewDidLoad ? 40 : 35 }
    
    // MARK: Init
    public init(
        error: PresentableError,
        isLoading: Binding<Bool>,
        tryAgainButtonTapped: (() -> Void)? = nil
    ) {
        self.error = error
        self._isLoading = isLoading
        self.tryAgainButtonTapped = tryAgainButtonTapped
    }
    
    // MARK: Body
    public var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "exclamationmark.circle.fill")
                .resizable()
                .frame(width: exclamationmark, height: exclamationmark)
                .foregroundColor(.themeVerySad)
            
            Text("\(error.title) 💩")
                .font(.montserratBold, 16)
                .foregroundColor(.themeText)
            
            Text(error.message)
                .font(.montserratRegular, 13)
                .foregroundColor(.themeText)
                .multilineTextAlignment(.center)
            
            // Try again
            if let tryAgainButtonTapped {
                Button("Try again", action: tryAgainButtonTapped)
                    .buttonStyle(PrimaryTextButtonStyle())
                    .isLoading(isLoading)
                    .disabled(isLoading)
            }
            
            // Report issue button – only when not loading
            if !isLoading {
                Button {
                    reportIssue()
                } label: {
                    Label("Report issue", systemImage: "envelope.badge")
                }
                .buttonStyle(PrimaryTextButtonStyle())
                .disabled(isCapturing)
                .opacity(isCapturing ? 0.6 : 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation { viewDidLoad = true }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        .padding(.horizontal, 50)
        // MARK: Sheets
        .sheet(isPresented: $showMailComposer) {
            MailComposer(
                subject: "[Bug] \(error.title)",
                body: buildMailBody(),
                attachment: screenshotData,
                onDismiss: { screenshotData = nil }
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareSheetItems())
        }
    }
    
    // MARK: – Private helpers
    @MainActor
    private func reportIssue() {
        isCapturing = true
        DispatchQueue.main.async {
            if let png = snapshot(scale: displayScale)?.pngData() {
                screenshotData = png
            }
            isCapturing = false
            if MFMailComposeViewController.canSendMail() {
                showMailComposer = true
            } else {
                showShareSheet = true
            }
        }
    }
    
    private func buildMailBody() -> String {
        """
        Steps to reproduce (please fill in):
        
        1.
        2.
        3.
        
        ---
        Title: \(error.title)
        Message: \(error.message)
        Device: \(UIDevice.current.model) • iOS \(UIDevice.current.systemVersion)
        App: v\(Bundle.main.appVersion) (\(Bundle.main.appBuild))
        """
    }
    
    private func shareSheetItems() -> [Any] {
        if let data = screenshotData {
            return [data]
        } else {
            return ["[Bug] \(error.title) – \(error.message)"]
        }
    }
}

// MARK: – Snapshot helper (iOS 16+)
@MainActor
extension View {
    /// Returns a UIImage snapshot of the current View.
    func snapshot(scale: CGFloat) -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale
        return renderer.uiImage
    }
}

// MARK: – Bundle helpers
private extension Bundle {
    var appVersion: String {
        (object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "?"
    }
    var appBuild: String {
        (object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "?"
    }
}

// MARK: – MailComposer wrapper
@MainActor
struct MailComposer: UIViewControllerRepresentable {
    var subject: String
    var body: String
    var attachment: Data?
    var onDismiss: () -> Void = {}
    
    func makeCoordinator() -> Coordinator { Coordinator(onDismiss: onDismiss) }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
		mailVC.setSubject(subject)
		mailVC.setMessageBody(body, isHTML: false)
        if let attachment {
			mailVC.addAttachmentData(
				attachment,
				mimeType: "image/png",
				fileName: "error.png"
			)
        }
		mailVC.mailComposeDelegate = context.coordinator
        return mailVC
    }
    
    func updateUIViewController(_: MFMailComposeViewController, context _: Context) {}
    
    final class Coordinator: NSObject, @MainActor MFMailComposeViewControllerDelegate {
        let onDismiss: () -> Void
        init(onDismiss: @escaping () -> Void) { self.onDismiss = onDismiss }
        @MainActor func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true, completion: onDismiss)
        }
    }
}

// MARK: – ShareSheet fallback
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
