import SwiftUI
import DesignSystem
import UIKit

struct InviteView: View {
    let code: String
    let managerName: String
    let title: String
    @State private var shareSheet: String? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    private var shareText: String {
        """
        You are invited to a feedback event '\(title)' with the code: \(code).
        Join here 
        \(link)
        Best
        \(managerName)
        """
    }
    
    private var link: String {
        "https://letsgrow.dk/invite/\(code)"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    infoSection
                    linkSection
                    shareButton
                }
                .padding(.horizontal, 18)
                .navigationTitle("Invite")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        SharedCloseButton { dismiss() }
                    }
                }
                .foregroundStyle(Color.themeDarkGray)
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .sheet(item: $shareSheet, id: \.self) { shareContent in
                ShareSheet(activityItems: [shareContent])
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Share the link with people you would like feedback from 🤝")
                .font(.montserratRegular, 14)
        }
    }
    
    private var linkSection: some View {
        VStack(alignment: .leading) {
            Text(link)
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(14)
                .font(.montserratMedium, 14)
                .overlay(copyButton, alignment: .trailing)
        }
    }
    
    private var copyButton: some View {
        Button(action: {
            shareSheet = link
        }) {
            HStack {
                Image(systemName: "document.on.document")
                    .font(.system(size: 16, weight: .regular))
            }
            .padding(.trailing, 12)
        }
        .buttonStyle(SecondaryToolbarButtonStyle())
        .frame(maxHeight: .infinity)
    }
    
    private var shareButton: some View {
        Button(action: {
            shareSheet = shareText
        }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                Text("Invite")
            }
        }
        .buttonStyle(LargeButtonStyle())
        .padding(.vertical, 8)
    }
}

/// ShareSheet is needed in InviteView since there is a problem with ShareLink when presenting from a sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    InviteView(code: "1234", managerName: "Manager name", title: "Event title")
}

