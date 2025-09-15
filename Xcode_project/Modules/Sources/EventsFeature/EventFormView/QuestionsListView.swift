import SwiftUI
import Model
import DesignSystem

struct QuestionsListView: View {
    
    let recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    @Binding var questionsInputs: [EventInput.QuestionInput]
    @State var presentSelectQuestionSheet: EventInput.QuestionInput?
    @State private var existingQuestionIndex: Int?
    
    var body: some View {
        Group {
            if questionsInputs.isEmpty {
                EmptyStateView(
                    title: "No questions",
                    message: "Tap '+' to add a question"
                ).frame(maxHeight: .infinity)
            } else {
                Form {
                    ForEach(Array(questionsInputs.enumerated()), id: \.offset) { index, questionsInput in
                        Button {
                            self.existingQuestionIndex = index
                            self.presentSelectQuestionSheet = questionsInput
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: questionsInput.feedbackType.systemImage)
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.title)
                                    .foregroundStyle(Color.themeTextSecondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(questionsInput.questionText)
                                        .foregroundColor(Color.themeText)
                                    Text(questionsInput.feedbackType.title)
                                        .font(.montserratRegular, 10)
                                        .foregroundColor(Color.themeTextSecondary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .onDelete { indexSet in
                        questionsInputs.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        questionsInputs.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
            }
        }
        .navigationTitle(Text("Questions"))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.themeBackground.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .font(.montserratRegular, 13)
        .foregroundColor(Color.themeTextSecondary)
        .sheet(
            item: $presentSelectQuestionSheet,
            content: { questionInput in
                QuestionPickerView(
                    existingQuestionIndex: self.existingQuestionIndex,
                    feedbackTypeSelected: questionInput.feedbackType,
                    questionTextField: questionInput.questionText
                ) { selectedQuestionInput, index in
                    if let index {
                        self.questionsInputs[index] = selectedQuestionInput
                    } else {
                        self.questionsInputs.append(selectedQuestionInput)
                    }
                }
            }
        )
        .overlay(alignment: .bottomTrailing, content: {
            Button {
                self.existingQuestionIndex = nil
                self.presentSelectQuestionSheet = .init(questionText: "", feedbackType: .emoji)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .padding(18)
                    .foregroundStyle(Color.themePrimaryAction.gradient)
            }
        })
    }
}

#Preview {
    NavigationStack {
        QuestionsListView(
            recentlyUsedQuestions: .init(),
            questionsInputs: .constant(
                [
                    .init(
                        questionText: "hjddshjd dshdh sdjhsd dshds hdhs h dsh dsh dsh dhs h dsh ds hhds hsd hsdhdsh ds",
                        feedbackType: .emoji
                    )
                ]
            ),
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        QuestionsListView(
            recentlyUsedQuestions: .init(),
            questionsInputs: .constant([]),
        )
    }
}
