import SwiftUI
import Model
import DesignSystem

extension FeedbackType {
    var isEnabled: Bool {
        switch self {
        case .emoji:
            return true
        case .comment:
            return false
        case .thumpsUpThumpsDown:
            return false
        case .opinion:
            return false
        case .oneToTen:
            return false
        }
    }
}

struct QuestionPickerView: View {
    
    let existingQuestionIndex: Int?
    let questionSelected: (_ input: EventInput.QuestionInput, _ optionalIndex: Int?) -> ()
    @State var feedbackTypeSelected: FeedbackType
    @State var questionTextField: String
    @State private var showFeedbackInfo = false
    @State private var showComingSoon = false
    @State private var comingSoonMessage: String = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isQuestionFocused: Bool
    
    init(
        existingQuestionIndex: Int?,
        feedbackTypeSelected: FeedbackType,
        questionTextField: String,
        questionSelected: @escaping (_ input: EventInput.QuestionInput, _ optionalIndex: Int?) -> ()
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
        let trimmed = questionTextField.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let input = EventInput.QuestionInput(questionText: trimmed, feedbackType: feedbackTypeSelected)
        questionSelected(input, existingQuestionIndex)
        dismiss()
    }
    
    private func showComingSoonAlert(_ feedbackType: FeedbackType) {
        comingSoonMessage = "Feedback type '\(feedbackType.title)' is coming soon. Stay tuned!"
        showComingSoon = true
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            let isSelected = type == feedbackTypeSelected
                            Button {
                                if type.isEnabled {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        feedbackTypeSelected = type
                                    }
                                } else {
                                    self.showComingSoonAlert(type)
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: type.systemImage)
                                        .symbolRenderingMode(.hierarchical)
                                        .font(.title3)
                                        .foregroundStyle(Color.themeTextSecondary)
                                    Text(type.title)
                                        .font(.montserratMedium, 10)
                                }
                                .opacity(type.isEnabled ? 1 : 0.5)
                                .saturation(type.isEnabled ? 1 : 0)
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
                                .overlay(alignment: .top) {
                                    if !type.isEnabled {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.clear)
                                                .background(.ultraThinMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                                            VStack(spacing: 6) {
                                                Image(systemName: "lock.fill")
                                                    .font(.headline)
                                                    .foregroundColor(.themeTextSecondary)
                                            }
                                        }
                                    }
                                }
                                .animation(.easeInOut(duration: 0.15), value: feedbackTypeSelected)
                            }
                            .buttonStyle(IconButtonStyle())
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
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(IconButtonStyle())
                    }
                    .padding(.trailing, 14)
                    .padding(.bottom, 14)
                }
                .sheet(isPresented: $showFeedbackInfo) {
                    FeedbackTypeInfoSheetView()
                }
                .alert("Coming Soon", isPresented: $showComingSoon) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(comingSoonMessage)
                }
                Form {
                    Section {
                        ZStack(alignment: .trailing) {
                            TextEditor(text: $questionTextField)
                                .focused($isQuestionFocused)
                                .font(.montserratMedium, 14)
                                .foregroundColor(Color.themeText)
                                .textInputAutocapitalization(.sentences)
                                .autocorrectionDisabled(false)
                            if !questionTextField.isEmpty {
                                Button {
                                    questionTextField = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                }
                                .buttonStyle(.plain)
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
            .background(Color.themeBackground)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Feedback question")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Account", systemImage: "checkmark", action: commitQuestion)
                    .disabled(!isQuestionValid)
                }
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
