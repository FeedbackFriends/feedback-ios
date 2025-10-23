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
                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            let isSelected = type == feedbackTypeSelected
                            Button {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    feedbackTypeSelected = type
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    type.image
                                        .symbolRenderingMode(.hierarchical)
                                        .font(.title3)
                                        .foregroundStyle(Color.themeTextSecondary)
                                    Text(type.title)
                                        .font(.montserratMedium, 10)
                                }
                                .frame(maxWidth: .infinity, minHeight: 70)
                                .padding(6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.themeSurface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelected ? Color.themePrimaryAction : Color.themeTextSecondary.opacity(0.2), lineWidth: isSelected ? 3 : 2)
                                )
                                .animation(.easeInOut(duration: 0.15), value: feedbackTypeSelected)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .background(Color.themeBackground)
                } header: {
                    HStack(spacing: 8) {
                        Spacer()
                        Button {
                            showFeedbackInfo = true
                        } label: {
                            Image.questionmarkCircle
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding(.trailing, 14)
                    .padding(.bottom, 14)
                }
                .padding(.top, 18)
                
                Form {
                    Section {
                        ZStack(alignment: .trailing) {
                            TextField("Enter question.", text: $questionTextField, axis: .vertical)
                                .focused($isQuestionFocused)
                                .font(.montserratMedium, 13)
                                .foregroundColor(Color.themeText)
                                .textInputAutocapitalization(.sentences)
                                .submitLabel(.go)
                                .padding(.trailing, 24)
                            
                            if !questionTextField.isEmpty {
                                Button {
                                    questionTextField = ""
                                } label: {
                                    Image.xmarkCircleFill
                                }
                                .foregroundStyle(Color.themeText)
                                .padding(.trailing, 4)
                                .padding(.top, 8)
                            }
                        }
                    } header: {
                        Text("Question")
                            .sectionHeaderStyle()
                            .padding(.leading, 12)
                    }
                }
                
            }
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
            .navigationTitle(text)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    SharedCloseButtonView {
                        self.dismiss()
                    }
                }
            }
            .onAppear {
                isQuestionFocused = true
            }
        }
    }
}

#Preview("Empty - Create") {
    QuestionPickerView.init(
        existingQuestionIndex: nil,
        feedbackTypeSelected: .emoji,
        questionTextField: "",
        questionSelected: { _, _ in }
    )
}

#Preview("Empty - Edit") {
    QuestionPickerView.init(
        existingQuestionIndex: 3,
        feedbackTypeSelected: .emoji,
        questionTextField: "",
        questionSelected: { _, _ in }
    )
}

#Preview("Long input") {
    QuestionPickerView.init(
        existingQuestionIndex: nil,
        feedbackTypeSelected: .emoji,
        questionTextField: "Aslkdjska lsak slksak sakaksl kaskask sa kask sak sak as k kask as kask  kas kask ask ask k as kas k sdjdsjds sd js djs sjd",
        questionSelected: { _, _ in }
    )
}
