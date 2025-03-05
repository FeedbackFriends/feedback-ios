import DesignSystem
import SwiftUI
import ComposableArchitecture
import Helpers
import Helpers
import Helpers

public struct FeedbackItemView: View {
    
    @FocusState var focusedField: FocusField?
    @State var didAppear = false
    
        @Bindable var store: StoreOf<FeedbackItem>
    
        public init(store: StoreOf<FeedbackItem>) {
            self.store = store
        }
    
    public var body: some View {
        VStack {
            VStack {
                Text("\(store.index+1) of \(store.count)")
                    .font(.montserratBold, 12)
                    .foregroundColor(.themeDarkGray)
                Text(store.question)
                    .font(.montserratRegular, 16)
                    .foregroundColor(.themeDarkGray)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 10)
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
                            .padding(.all, 16)
                            .font(.montserratRegular, 15)
                            .foregroundColor(.themeDarkGray)
                            .scrollContentBackground(.hidden)
                            .background(Color.themeWhite)
                            .cornerRadius(Theme.cornerRadius)
                            .focused($focusedField, equals: .field)
                            
                    }
                    .onAppear {
                        store.send(.onAppear)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            HStack {
                if store.elementType == .trailing {
                    if store.count > 1 {
                        Button {
                            store.send(.onPreviousButtonTapped)
                        } label: {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .fontWeight(Font.Weight.semibold)
                                .foregroundColor(.themeDarkGray)
                        }
                        .padding(.trailing, 8)
                        .buttonStyle(OpacityButtonStyle())
                    }
                    Button("Submit") {
                        store.send(.onSubmitFeedbackTapped)
                    }
                    .buttonStyle(LargeButtonStyle())
                    .disabled(store.disableSendButton)
                    .isLoading(store.submitFeedbackInFlight)
                } else {
                    if store.elementType == .center {
                        Button {
                            store.send(.onPreviousButtonTapped)
                        } label: {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .fontWeight(Font.Weight.semibold)
                                .foregroundColor(.themeDarkGray)
                        }
                        .padding(.trailing, 8)
                        .buttonStyle(OpacityButtonStyle())
                    }
                    Button("Next") {
                        store.send(.onNextButtonTapped)
                    }
                    .buttonStyle(LargeButtonStyle())
                    .disabled(store.selectedEmoji == nil ? true : false)
                }
            }
            .padding(Theme.padding)
            .offset(y: self.didAppear ? 0 : 200)
            .onAppear {
                store.send(.onAppear)
                guard case .leading = store.elementType else {
                    self.didAppear = true
                    return
                }
                Task {
                    try await Task.sleep(for: .seconds(0.5))
                    withAnimation(.bouncy(duration: 1)) {
                        self.didAppear = true
                    }
                }
            }
        }
        .onTapGesture {
            store.send(.onTapOutsideTextfield)
        }
        .synchronize($store.focusedField, self.$focusedField)
    }
}
