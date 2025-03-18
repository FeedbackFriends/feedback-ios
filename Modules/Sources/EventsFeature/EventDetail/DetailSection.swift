import Helpers
import DesignSystem
import SwiftUI
import Helpers

struct DetailSectionView: View {
    
    let event: ManagerEvent
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                detailSectionView
                eventPinSectionView
                questionsSectionView
            }
            .padding()
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
        .background(Color.themeBackground)
        .lineSpacing(5)
        .foregroundStyle(Color.themeDarkGray)
    }
}

private extension DetailSectionView {
    
    var detailSectionView: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    if let agenda = event.agenda {
                        Text("Agenda")
                            .font(.montserratSemiBold, 13)
                        Text(agenda)
                            .multilineTextAlignment(.leading)
                            .font(.montserratRegular, 13)
                    }
                    Text("Date")
                        .font(.montserratSemiBold, 13)
                    Text(event.formattedDate)
                        .font(.montserratRegular, 13)
                    if let receivedFedeback = event.feedbackSummary?.totalFeedback {
                        Text("Received feedback")
                            .font(.montserratSemiBold, 13)
                        Text(receivedFedeback.description)
                            .font(.montserratRegular, 13)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                if let feedback = event.feedbackSummary {
                    makeFeedbackPercentageBarView(feedback: feedback)
                } else {
                    makeEmptyFeedbackBarView()
                }
            }
            .font(.montserratRegular, 14)
            .background(Color.themeWhite)
            .cornerRadius(14)
        } header: {
            Text("DETAILS")
                .font(.montserratBold, 14)
                .foregroundColor(Color.themeDarkGray)
        }
    }
    
    var eventPinSectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PIN CODE")
                .font(.montserratSemiBold, 14)
                .foregroundStyle(Color.themeDarkGray)
            VStack(alignment: .trailing, spacing: 12) {
                Text("\(event.pinCode.description)")
                    .frame(maxWidth: .infinity)
                    .font(.montserratMedium, 30)
                    .foregroundStyle(Color.themeDarkGray.gradient)
                    .kerning(10)
                    .padding(.vertical, 12)
                    .overlay(
                        alignment: .trailing,
                        content: {
                            ShareLink(item: event.pinCode) {
                                HStack {
                                    Image(systemName: "document.on.document")
                                        .font(.system(size: 16, weight: .regular))
                                }
                                .padding(.trailing, 12)
                            }
                            .buttonStyle(SecondaryToolbarButtonStyle())
                            .frame(maxHeight: .infinity)
                        }
                    )
                    .background(Color.themeWhite)
                    .cornerRadius(14)
            }
            .frame(maxWidth: .infinity)
            .font(.montserratRegular, 14)
            
        }
    }
    
    @ViewBuilder
    var questionsSectionView: some View {
        Section {
            ForEach(Array(zip(event.questions.indices, event.questions)), id: \.0) { index, question in
                questionView(question: question, index: index)
                    .disabled(event.feedbackSummary == nil)
            }
            
        } header: {
            Text("QUESTIONS")
                .font(.montserratSemiBold, 14)
                .foregroundColor(Color.themeDarkGray)
        }
    }
    
    func smileyView(_ feedback: QuestionFeedbackSummary) -> some View {
        Group {
            VStack(alignment: .leading) {
                HStack {
                    HStack(spacing: 4) {
                        Image.veryHappy
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(feedback.veryHappyCount.description)
                    }
                    HStack(spacing: 4) {
                        Image.happy
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(feedback.happyCount.description)
                    }
                    HStack(spacing: 4) {
                        Image.sad
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(feedback.sadCount.description)
                    }
                    HStack(spacing: 4) {
                        Image.verySad
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(feedback.verySadCount.description)
                    }
                }
            }
            .font(.montserratSemiBold, 12)
        }
    }
    
    func questionView(question: ManagerQuestion, index: Int) -> some View {
        GroupBox {
                    DisclosureGroup(
                        content: {
                            if let feedback = question.feedback {
                                VStack(spacing: 0) {
                                    ForEach(feedback) { feedback in
                                        FeedbackRowView(feedback: feedback)
                                    }
                                }
                            }
                        },
                        label: {
                            VStack(spacing: 10) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(question.questionText)
                                            .font(.montserratRegular, 13)
                                            .multilineTextAlignment(.leading)
                                        if let feedback = question.feedbackSummary {
                                            smileyView(feedback)
                                        }
                                    }
                                    Spacer()
                                    VStack(alignment: .leading, spacing: 12) {
                                        if let feedback = question.feedbackSummary, feedback.totalFeedback > 2 {
                                            makePieChartView(feedback: feedback)
                                                .frame(width: 34, height: 34)
                                        }
                                    }
                                }
                                .padding(.top, 16)
                                .padding(.trailing, 16)
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                
                Color.clear.frame(height: 10)
        }
        .groupBoxStyle(CustomGroupBoxStyle())
    }
}

#Preview("Detail section with feedback n stuff") {
    NavigationStack {
        DetailSectionView(event: .mock())
            .navigationTitle("Event with feedback n stuff")
    }
}


#Preview("Detail section with empty event") {
    NavigationStack {
        DetailSectionView(event: .mockEmpty)
            .navigationTitle("Event with empty feedback")
    }
}

