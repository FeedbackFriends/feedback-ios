import Helpers
import SwiftUI
import DesignSystem

func feedbackPercentageBarView(feedback: FeedbackSegmentationStats) -> some View {
    GeometryReader { proxy in
        let withPercent = proxy.size.width/100
        HStack(spacing: 0) {
            Color.themeRed.frame(width: feedback.verySadPercentage * withPercent)
            Color.themeOrange.frame(width: feedback.sadPercentage * withPercent)
            Color.themeYellow.frame(width: feedback.happyPercentage * withPercent)
            Color.themeGreen.frame(width: feedback.veryHappyPercentage * withPercent)
        }
        .unredacted()
    }
    .frame(minHeight: 10)
}

func emptyFeedbackSegmentationStatsView() -> some View {
    GeometryReader { proxy in
        HStack(spacing: 0) {
            Color.gray.opacity(0.2).frame(width: proxy.size.width)
        }
        .unredacted()
    }
    .frame(minHeight: 24)
    .overlay(alignment: .center) {
        Text("No feedback received")
            .font(.montserratMedium, 12)
            .foregroundColor(Color.themeDarkGray.opacity(0.8))
    }
}
