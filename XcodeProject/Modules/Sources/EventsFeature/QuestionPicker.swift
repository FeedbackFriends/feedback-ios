import SwiftUI
import DesignSystem
import Helpers

public struct QuestionPicker: View {
    
    @State var enteredString = ""
    @State var navigateToTemplateQuestionSheet = false
    @Binding var questions: [EventInput.QuestionInput]
    @FocusState var textFieldFocused: Bool
    let recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    
    public init(
        enteredString: String = "",
        showSheet: Bool = false,
        questions: Binding<[EventInput.QuestionInput]>,
        recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    ) {
        self.enteredString = enteredString
        self.navigateToTemplateQuestionSheet = showSheet
        self._questions = questions
        self.recentlyUsedQuestions = recentlyUsedQuestions
    }
    
    public var body: some View {
        content
            .animation(.easeOut(duration: 0.5), value: questions)
            .animation(.easeOut(duration: 0.5), value: enteredString)
            .foregroundColor(.themeDarkGray)
            .font(.montserratMedium, 14)
    }
}

private extension QuestionPicker {
    var content: some View {
        Section {
            ForEach(self.$questions, id: \.self, editActions: .all) {
                Text($0.wrappedValue.questionText)
                    .padding(.vertical, 4)
            }
            HStack {
                TextField(
                    "New feedback question",
                    text: $enteredString
                )
                .focused($textFieldFocused)
                Button {
                    withAnimation {
                        questions.append(.init(questionText: enteredString, feedbackType: .emoji))
                    }
                    enteredString = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .scaledToFit()
                }
                .buttonStyle(PrimaryToolbarButtonStyle())
                .disabled(enteredString.isEmpty)
            }
            .padding(.vertical, 4)
        } header: {
            HStack {
                Text("Questions")
                    .sectionHeaderStyle()
                Spacer()
                Button("Recently used") {
                    textFieldFocused = false
                    navigateToTemplateQuestionSheet = true
                }
                .buttonStyle(PrimaryToolbarButtonStyle())
                
            }
            .sheet(isPresented: $navigateToTemplateQuestionSheet) {
                NavigationStack {
                    ChooseTemplateView(recentlyUsedQuestions: recentlyUsedQuestions) { questions in
                        for element in questions {
                            self.navigateToTemplateQuestionSheet = false
                            withAnimation {
                                self.questions.append(.init(questionText: element.questionText, feedbackType: element.feedbackType))
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        } footer: {
            HStack {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 18, height: 18)
                Text("Remember that the order of the questions can be important. ")
                    .font(.montserratRegular, 12)
            }
            .foregroundColor(Color.themeDarkGray)
        }
    }
}

struct ChooseTemplateView: View {
    
    @State var editMode: EditMode = .active
    @State private var selectedQuestions = Set<RecentlyUsedQuestions>()
    let recentlyUsedQuestions: [RecentlyUsedQuestions]
    let addTemplateQuestions: (Set<RecentlyUsedQuestions>) -> Void
    
    init(
        recentlyUsedQuestions: Set<RecentlyUsedQuestions>,
        addTemplateQuestions: @escaping (Set<RecentlyUsedQuestions>) -> Void
    ) {
        self.recentlyUsedQuestions = Array(recentlyUsedQuestions.sorted(by: { $0.updatedAt > $1.updatedAt }))
        self.addTemplateQuestions = addTemplateQuestions
    }
    
    var body: some View {
        List(
            recentlyUsedQuestions, id: \.self, selection: $selectedQuestions
        ) { question in
            Text(question.questionText)
                .font(.montserratRegular, 14)
                .fixedSize(horizontal: false, vertical: false)
                .multilineTextAlignment(.leading)
        }
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Recently used")
        .environment(\.editMode, $editMode)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    withAnimation {
                        addTemplateQuestions(selectedQuestions)
                    }
                }
                .buttonStyle(PrimaryToolbarButtonStyle())
                .disabled(selectedQuestions.isEmpty)
            }
        }
    }
}

#Preview {
    @Previewable @State var questions: [EventInput.QuestionInput] = []
    NavigationStack {
        Form {
            QuestionPicker(
                enteredString: "Hello",
                showSheet: false,
                questions: $questions,
                recentlyUsedQuestions: .init([
                    .init(questionText: "Hello world", feedbackType: .emoji, updatedAt: Date())
                ])
            )
        }
    }
}
