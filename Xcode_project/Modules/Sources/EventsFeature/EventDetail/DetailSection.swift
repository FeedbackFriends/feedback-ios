import Model
import DesignSystem
import SwiftUI

struct DetailSectionView: View {
    
    let event: ManagerEvent
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                detailSectionView
                eventPinSectionView
                    .padding(.top, 4)
                questionsSectionView
                    .padding(.top, 4)
            }
            .padding()
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
        .background(Color.themeBackground)
        .lineSpacing(5)
        .foregroundStyle(Color.themeText)
    }
}

private extension DetailSectionView {
    
    var detailSectionView: some View {
        VStack(alignment: .leading) {
            Text("DETAILS")
                .sectionHeaderStyle()
                .padding(.leading, 18)
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
                    FeedbackPercentageBarView(feedback: feedback.segmentationStats)
                } else {
                    EmptyFeedbackSegmentationStatsView()
                }
            }
            .font(.montserratRegular, 14)
            .background(Color.themeSurface)
            .cornerRadius(14)
        }
    }
    
    var eventPinSectionView: some View {
        VStack(alignment: .leading) {
            Text("PIN CODE")
                .sectionHeaderStyle()
                .padding(.leading, 18)
            VStack(alignment: .trailing, spacing: 12) {
                Text("\(event.pinCode.value.description)")
                    .frame(maxWidth: .infinity)
                    .font(.montserratMedium, 30)
                    .kerning(10)
                    .padding(.vertical, 12)
                    .overlay(
                        alignment: .trailing,
                        content: {
                            ShareLink(item: event.pinCode.value) {
                                HStack {
                                    Image(systemName: "document.on.document")
                                        .font(.system(size: 16, weight: .regular))
                                }
                                .padding(.trailing, 12)
                            }
                            .buttonStyle(PrimaryTextButtonStyle())
                            .frame(maxHeight: .infinity)
                        }
                    )
					.background(Color.themeSurface)
                    .cornerRadius(14)
            }
            .frame(maxWidth: .infinity)
            .font(.montserratRegular, 14)
        }
    }
    
    @ViewBuilder
    var questionsSectionView: some View {
        VStack(alignment: .leading) {
            Text("QUESTIONS")
                .sectionHeaderStyle()
                .padding(.leading, 18)
            ForEach(Array(zip(event.questions.indices, event.questions)), id: \.0) { index, question in
                QuestionView(question: question, index: index)
                    .disabled(event.feedbackSummary == nil)
                
            }
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
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Comments")
                            .font(.montserratSemiBold, 13)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if question.feedbackSummary == nil || question.feedbackSummary?.countStats.commentsCount == 0 {
                            Text("No comments yet")
                                .font(.montserratRegular, 14)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(question.feedback.sorted(by: {
                                $0.createdAt > $1.createdAt
                            })) { feedback in
                                FeedbackCommentRowView(feedback: feedback)
                            }
                        }
                    }
					.padding(.top, 16)
					.foregroundStyle(Color.themeTextSecondary)
					
                },
                label: {
                    VStack(spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Question \(index + 1)")
                                    .font(.montserratSemiBold, 13)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(question.questionText)
                                    .font(.montserratRegular, 13)
                                    .multilineTextAlignment(.leading)
                                if let feedback = question.feedbackSummary {
                                    smileyView(feedback.countStats)
                                    FeedbackPercentageBarView(
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
                        Image.verySad
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(feedback.verySadCount.description)
                    }
                    HStack(spacing: 4) {
                        Image.sad
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(feedback.sadCount.description)
                    }
                    HStack(spacing: 4) {
                        Image.happy
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(feedback.happyCount.description)
                    }
                    HStack(spacing: 4) {
                        Image.veryHappy
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(feedback.veryHappyCount.description)
                    }
                }
            }
            .font(.montserratSemiBold, 12)
        }
    }
}

#Preview("Empty feedback") {
    NavigationStack {
		DetailSectionView(
			event: .init(
				id: UUID(),
				title: "Title",
				agenda: "Agenda",
				date: Date(),
				pinCode: PinCode(value: "1234"),
				durationInMinutes: 60,
				location: "Hellerup",
				ownerInfo: .init(
					name: "Nicolai",
					email: "Email",
					phoneNumber: "Phonenumber"
				),
				feedbackSummary: nil,
				questions: [
					.init(
						id: UUID(),
						questionText: "Why whyyyy whyyy",
						feedbackType: .emoji,
						feedback: [],
						feedbackSummary: nil
					)
				]
			)
		)
		.navigationTitle("Event with empty feedback")
    }
}

#Preview("With feedback") {
	NavigationStack {
		DetailSectionView(
			event: .init(
				id: UUID(),
				title: "Title",
				agenda: "Agenda",
				date: Date(),
				pinCode: PinCode(value: "1234"),
				durationInMinutes: 60,
				location: "Hellerup",
				ownerInfo: .init(
					name: "Nicolai",
					email: "Email",
					phoneNumber: "Phonenumber"
				),
				feedbackSummary: .init(
					segmentationStats: .init(
						verySadPercentage: 30,
						sadPercentage: 30,
						happyPercentage: 20,
						veryHappyPercentage: 20
					),
					countStats: .init(
						verySadCount: 10,
						sadCount: 10,
						happyCount: 10,
						veryHappyCount: 10,
						commentsCount: 10,
						uniqueParticipantFeedback: 10
					),
					unseenCount: 8
				),
				questions: [
					.init(
						id: UUID(),
						questionText: "Why whyyyy whyyy",
						feedbackType: .emoji,
						feedback: [
							.init(
								type: .emoji(emoji: .happy, comment: "Hello world"),
								questionId: UUID(),
								seenByManager: false,
								createdAt: Date()
							)
						],
						feedbackSummary: .init(
							segmentationStats: .init(
								verySadPercentage: 30,
								sadPercentage: 30,
								happyPercentage: 20,
								veryHappyPercentage: 20
							),
							countStats: .init(
								verySadCount: 10,
								sadCount: 10,
								happyCount: 10,
								veryHappyCount: 10,
								commentsCount: 10,
								uniqueParticipantFeedback: 10
							),
							unseenCount: 10
						)
					)
				]
			)
		)
		.navigationTitle("Event with empty feedback")
	}
}
