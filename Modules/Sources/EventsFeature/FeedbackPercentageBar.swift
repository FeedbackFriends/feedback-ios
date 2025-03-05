import Helpers
import SwiftUI
import DesignSystem

public func makeFeedbackPercentageBarView(feedback: FeedbackSummary) -> some View {
    GeometryReader { proxy in
        let withPercent = proxy.size.width/100
        HStack(spacing: 0) {
            Color.themeGreen.frame(width: feedback.veryHappyPercentage * withPercent)
            Color.themeYellow.frame(width: feedback.happyPercentage * withPercent)
            Color.themeOrange.frame(width: feedback.sadPercentage * withPercent)
            Color.themeRed.frame(width: feedback.verySadPercentage * withPercent)
        }
        .unredacted()
    }
    .frame(minHeight: 10)
}

public func makeEmptyFeedbackBarView() -> some View {
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

@MainActor
public func makePieChartView(feedback: QuestionFeedbackSummary) -> some View {
    GeometryReader { proxy in
        PieChart(
            [
                (Color.themeRed, Double(feedback.verySadCount)),
                (Color.themeOrange, Double(feedback.sadCount)),
                (Color.themeYellow, Double(feedback.happyCount)),
                (Color.themeGreen, Double(feedback.veryHappyCount))
            ]
        )
        .unredacted()
    }
}
