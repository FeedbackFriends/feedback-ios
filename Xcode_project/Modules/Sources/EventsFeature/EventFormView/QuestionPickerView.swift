import SwiftUI
import Domain
import DesignSystem

public struct QuestionPickerView: View {
    
    let existingQuestionIndex: Int?
    let questionSelected: (_ input: EventInput.QuestionInput, _ optionalIndex: Int?) -> Void
    var text: String {
        if existingQuestionIndex != nil {
            "Edit"
        } else {
            "Add"
        }
    }
    @State var feedbackTypeSelected: FeedbackType
    @State var questionTextField: String
    @State private var showFeedbackInfo = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isQuestionFocused: Bool
    
    public init(
        existingQuestionIndex: Int?,
        feedbackTypeSelected: FeedbackType,
        questionTextField: String,
        questionSelected: @escaping (_ input: EventInput.QuestionInput, _ optionalIndex: Int?) -> Void
    ) {
        self.existingQuestionIndex = existingQuestionIndex
        self._feedbackTypeSelected = State(initialValue: feedbackTypeSelected)
        self._questionTextField = State(initialValue: questionTextField)
        self.questionSelected = questionSelected
    }
    
    private var isQuestionValid: Bool {
        !questionTextField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func commitQuestion() {
        Task {
            withAnimation {
                dismiss()
            }
            try await Task.sleep(for: .seconds(0.3))
            let trimmed = questionTextField.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            let input = EventInput.QuestionInput(questionText: trimmed, feedbackType: feedbackTypeSelected)
            withAnimation {
                questionSelected(input, existingQuestionIndex)
            }
        }
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                        ForEach(FeedbackType.allCases, id: \.self) { question in
                            let isSelected = question == feedbackTypeSelected
                            Button {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    feedbackTypeSelected = question
                                }
                            } label: {
                                VStack {
                                    question.image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                        .foregroundStyle(Color.themeText)
                                    Text(question.title)
                                        .font(.montserratSemiBold, 9)
                                        .foregroundStyle(Color.themeTextSecondary)
                                }
                                .padding(2)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.themeSurface)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(isSelected ? Color.themePrimaryAction : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(ScalingButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .background(Color.themeBackground)
                } header: {
                    HStack(spacing: 8) {
                        Text("Choose feedback type")
                            .foregroundStyle(Color.themeText)
                            .font(.montserratMedium, 14)
                        Spacer()
                        Button {
                            showFeedbackInfo = true
                        } label: {
                            Image.questionmarkCircle
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.themeText)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.leading, 20)
                }
                .padding(.top, 18)
                
                Form {
                    Section {
                        TextField("Enter question.", text: $questionTextField, axis: .vertical)
                            .focused($isQuestionFocused)
                            .font(.montserratMedium, 12)
                            .foregroundColor(Color.themeText)
                            .textInputAutocapitalization(.sentences)
                            .submitLabel(.go)
                            .padding(.trailing, 24)
                            .overlay(alignment: .trailing) {
                                if !questionTextField.isEmpty {
                                    Button {
                                        questionTextField = ""
                                    } label: {
                                        Image.xmarkCircleFill
                                    }
                                    .foregroundStyle(Color.themeTextSecondary)
                                }
                            }
                            .padding(.trailing, 4)
                    } header: {
                        Text("Question")
                            .sectionHeaderStyle()
                    }
                }
                
            }
            .sensoryFeedback(.selection, trigger: feedbackTypeSelected)
            .overlay(alignment: .bottom) {
                Button(text, action: commitQuestion)
                    .buttonStyle(LargeButtonStyle())
                    .disabled(!isQuestionValid)
                    .padding(14)
            }
            .sheet(isPresented: $showFeedbackInfo) {
                FeedbackTypeInfoSheetView()
            }
            .background(Color.themeBackground)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView {
                        self.dismiss()
                    }
                }
            }
            .onAppear {
                isQuestionFocused = true
            }
            .background {
                /// this makes the keyboard to appear with a single animation
                FirstResponderFieldView()
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .background(Color.themeSurface.ignoresSafeArea())
            }
        }
    }
}

#Preview("Empty - Create") {
    QuestionPickerView(
        existingQuestionIndex: nil,
        feedbackTypeSelected: .emoji,
        questionTextField: "",
        questionSelected: { _, _ in }
    )
}

#Preview("Empty - Edit") {
    QuestionPickerView(
        existingQuestionIndex: 3,
        feedbackTypeSelected: .emoji,
        questionTextField: "",
        questionSelected: { _, _ in }
    )
}

#Preview("Long input") {
    QuestionPickerView(
        existingQuestionIndex: nil,
        feedbackTypeSelected: .emoji,
        questionTextField: "Aslkdjska lsak slksak sakaksl kaskask sa kask sak sak as k kask as kask kas kask ask ask k as kas k sdjdsjds sd js djs sjd",
        questionSelected: { _, _ in }
    )
}

