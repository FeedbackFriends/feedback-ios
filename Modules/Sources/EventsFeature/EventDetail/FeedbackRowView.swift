import APIClient
import SwiftUI

struct FeedbackRowView: View {
    
    let feedback: Feedback
    
    var body: some View {
        switch feedback.type {
        case .emoji(emoji: let emoji, comment: let optionalComment):
            if let comment = optionalComment {
                HStack {
                    emoji.icon
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text(comment)
                        .font(.montserratRegular, 14)
                    Spacer()
                    if feedback.isNew {
                        Text("New")
                            .font(.montserratMedium, 12)
                            .foregroundColor(Color.themeDarkGray)
                    }
                }
                .padding(.vertical, 8)
            }
        default:
            Text("To be implemented")
        }
    }
}
