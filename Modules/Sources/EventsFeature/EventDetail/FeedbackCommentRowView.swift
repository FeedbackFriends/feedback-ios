import Helpers
import SwiftUI
import DesignSystem

struct FeedbackCommentRowView: View {
    
    let feedback: Feedback
    
    var body: some View {
        switch feedback.type {
        case .emoji(emoji: let emoji, comment: let optionalComment):
            if let comment = optionalComment {
                HStack(alignment: .top, spacing: 8) {
                    emoji.icon
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment)
                            .font(.montserratRegular, 14)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack {
                            if !feedback.seenByManager {
                                Text("New")
                                    .font(.montserratBold, 8)
                                    .padding(2)
                                    .padding(.horizontal, 4)
                                    .foregroundStyle(Color.themeWhite)
                                    .background(Color.blue.opacity(0.5).gradient)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                            }
                            Text(feedback.createdAt.timeAgo())
                                .foregroundStyle(Color.gray)
                                .font(.montserratRegular, 10)
                            Spacer()
                            
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        default:
            Text("To be implemented")
        }
    }
}
