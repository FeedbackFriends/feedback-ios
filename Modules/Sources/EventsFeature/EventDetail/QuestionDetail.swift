import ComposableArchitecture
import Helpers
import DesignSystem
import SwiftUI
import Helpers

struct QuestionDetailView: View {
    
    let questions: [ManagerQuestion]
    @State var selectedQuestionIndex: Int
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $selectedQuestionIndex) {
                    ForEach(Array(questions.enumerated()), id: \.element) { index, question in
                        questionView(question)
                            .tag(index)
                            .navigationTitle("\(selectedQuestionIndex + 1) of \(questions.count)")
                    }
                }
            }
            .scrollIndicators(.hidden)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .lineSpacing(7)
            .scrollContentBackground(.hidden)
            .background(Color.themeBackground)
            .interactiveDismissDisabled(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation {
                            self.selectedQuestionIndex = selectedQuestionIndex - 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    }
                    .disabled(selectedQuestionIndex == 0)
                    .buttonStyle(IconToolbarStyle())
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation {
                            self.selectedQuestionIndex = selectedQuestionIndex + 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    }
                    .disabled(selectedQuestionIndex == questions.count - 1)
                    .buttonStyle(IconToolbarStyle())
                }
            }
            VStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(LargeButtonStyle())
                
                .padding(.horizontal, Theme.padding)
                .padding(.top, 16)
                .background(
                    .thinMaterial,
                    in: Rectangle()
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

private extension QuestionDetailView {
    
    func questionView(_ question: ManagerQuestion) -> some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                Text(question.questionText)
                    .font(.montserratBold, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let summary = question.feedbackSummary {
                    smileyView(summary.countStats)
                        .foregroundColor(.themeDarkGray)
                        .offset(y: -6)
                    if summary.countStats.commentsCount > 0 {
                        VStack(alignment: .leading) {
                            Text("Comments")
                                .font(.montserratBold, 15)
                            ForEach(question.feedback) { feedback in
                                FeedbackCommentRowView(feedback: feedback)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.themeDarkGray)
            .padding(.all, Theme.padding)
            .background(
                Color.themeWhite
                    .cornerRadius(Theme.cornerRadius)
            )
            .padding(.all, Theme.padding)
            .padding(.bottom, 70)
        }
        
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

