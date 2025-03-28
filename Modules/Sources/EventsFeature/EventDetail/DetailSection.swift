import Helpers
import DesignSystem
import SwiftUI

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
                    if let totalFeedback = event.feedbackSummary?.countStats.uniqueParticipantFeedback {
                        Text("Received feedback")
                            .font(.montserratSemiBold, 13)
                        Text(totalFeedback.description)
                            .font(.montserratRegular, 13)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                if let feedback = event.feedbackSummary {
                    makeFeedbackPercentageBarView(feedback: feedback.segmentationStats)
                } else {
                    makeEmptyFeedbackSegmentationStatsView()
                }
            }
            .font(.montserratRegular, 14)
            .background(Color.themeWhite)
            .cornerRadius(14)
        } header: {
            Text("Details")
                .sectionHeaderStyle()
        }
    }
    
    var eventPinSectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pincode")
                .sectionHeaderStyle()
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
                if question.feedbackSummary == nil {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Question \(index+1)")
                            .font(.montserratSemiBold, 13)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(question.questionText)
                            .font(.montserratRegular, 14)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
                    .background(Color.white)
                    .cornerRadius(14)
                } else {
                    QuestionView(question: question, index: index)
                        .disabled(event.feedbackSummary == nil)
                }
            }
            
        } header: {
            Text("Questions")
                .sectionHeaderStyle()
        }
    }
}

struct QuestionView: View {
    let question: ManagerQuestion
    let index: Int
    @State private var isExpanded: Bool = true
    var body: some View {
        GroupBox {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    VStack(spacing: 0) {
                        ForEach(question.feedback) { feedback in
                            FeedbackRowView(feedback: feedback)
                        }
                    }.padding(.top, 16)
                },
                label: {
                    VStack(spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Question \(index+1)")
                                    .font(.montserratSemiBold, 13)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(question.questionText)
                                    .font(.montserratRegular, 13)
                                    .multilineTextAlignment(.leading)
                                if let feedback = question.feedbackSummary {
                                    smileyView(feedback.countStats)
                                    makeFeedbackPercentageBarView(
                                        feedback: feedback.segmentationStats
                                    )
                                    .frame(height: 8)
                                    .cornerRadius(4)
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
    
    func smileyView(_ feedback: FeedbackCountStats) -> some View {
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
}


#Preview("Detail section with empty event") {
    NavigationStack {
        DetailSectionView(event: .mockEmpty)
            .navigationTitle("Event with empty feedback")
    }
}

#Preview("Detail section with feedback n stuff") {
    NavigationStack {
        DetailSectionView(event: .mock())
            .navigationTitle("Event with feedback n stuff")
    }
}

#Preview("Questions") {
    QuestionView(
        question: .init(
            id: UUID(),
            questionText: "aksndkajndakjs sakj askjsa sakj sakjsa sakjas kjsa",
            feedbackType: .emoji,
            feedback: [],
            feedbackSummary: nil
        ),
        index: 0
    )
}
