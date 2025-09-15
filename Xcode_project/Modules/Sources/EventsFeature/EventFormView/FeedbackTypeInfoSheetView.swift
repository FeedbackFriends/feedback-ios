import SwiftUI
import Domain
import DesignSystem

struct FeedbackTypeInfoSheetView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            List(FeedbackType.allCases, id: \.self) { type in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: type.systemImage)
                        .font(.title3)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(type.title)
                            .font(.montserratSemiBold, 15)
                        Text(type.helpDescription)
                            .font(.montserratRegular, 13)
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    SharedCloseButtonView { dismiss() }
                }
            }
            .background(Color.themeBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Feedback types")
            .navigationBarTitleDisplayMode(.large)
            .foregroundStyle(Color.themeText)
        }
    }
}

extension FeedbackType {
    var title: String {
        switch self {
        case .emoji: return "Emoji"
        case .comment: return "Comment"
        case .thumpsUpThumpsDown: return "Thumbs"
        case .opinion: return "Opinion"
        case .oneToTen: return "1–10"
        }
    }
    
    var systemImage: String {
        switch self {
        case .emoji: return "face.smiling"
        case .comment: return "text.bubble"
        case .thumpsUpThumpsDown: return "hand.thumbsup"
        case .opinion: return "quote.bubble"
        case .oneToTen: return "number"
        }
    }
    
    var helpDescription: String {
        switch self {
        case .emoji: return "Pick an emoji reaction. Great for quick vibes."
        case .comment: return "Write freeform text. Best for detailed feedback."
        case .thumpsUpThumpsDown: return "Simple thumbs up/down. Fast sentiment signal."
        case .opinion: return "Express your level of agreement, from Strongly Disagree to Strongly Agree."
        case .oneToTen: return "Rate on a 1–10 scale for finer granularity."
        }
    }
}

#Preview {
    FeedbackTypeInfoSheetView()
}
