import DesignSystem
import ComposableArchitecture
import Helpers
import SwiftUI

public struct EmojiFeedbackView: View {
    
    @FocusState var commentTextfieldFocused: Bool
    @State var didAppear = false
    
    @Bindable var store: StoreOf<EmojiFeedback>
    
    public init(store: StoreOf<EmojiFeedback>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            HStack {
                Button {
                    store.send(.onSmileyTapped(.verySad), animation: .bouncy)
                } label: {
                    Image.verySad
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .grayscale(store.selectedEmoji == .verySad ? 0.0: 1.0)
                        .padding(store.selectedEmoji == .verySad ? 10 : 13)
                }
                Button {
                    store.send(.onSmileyTapped(.sad), animation: .bouncy)
                } label: {
                    Image.sad
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .grayscale(store.selectedEmoji == .sad ? 0.0: 1.0)
                        .padding(store.selectedEmoji == .sad ? 10 : 13)
                }
                
                Button {
                    store.send(.onSmileyTapped(.happy), animation: .bouncy)
                } label: {
                    Image.happy
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .grayscale(store.selectedEmoji == .happy ? 0.0: 1.0)
                        .padding(store.selectedEmoji == .happy ? 10 : 13)
                }
                Button {
                    store.send(.onSmileyTapped(.veryHappy), animation: .bouncy)
                } label: {
                    Image.veryHappy
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .grayscale(store.selectedEmoji == .veryHappy ? 0.0: 1.0)
                        .padding(store.selectedEmoji == .veryHappy ? 10 : 13)
                }
            }
            if store.selectedEmoji != nil {
                VStack(alignment: .leading) {
                    Text("Please elaborate why")
                        .font(.montserratSemiBold, 13)
                        .foregroundColor(.themeDarkGray)
                    TextEditor(text: $store.commentTextField)
                        .padding(.all, 12)
                        .font(.montserratRegular, 14)
                        .foregroundColor(.themeDarkGray)
                        .scrollContentBackground(.hidden)
                        .background(Color.themeWhite)
                        .cornerRadius(Theme.cornerRadius)
                        .focused($commentTextfieldFocused)
                }
                .animation(.bouncy, value: store.selectedEmoji)
                .transition(.blurReplace)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .animation(.easeInOut(duration: 0.2), value: store.selectedEmoji)
        .onTapGesture {
            store.send(.onTapOutsideTextfield)
        }
        .sensoryFeedback(.selection, trigger: store.selectedEmoji)
        .synchronize($store.commentTextfieldFocused, self.$commentTextfieldFocused)

    }
}
