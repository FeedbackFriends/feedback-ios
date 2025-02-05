////
////  File.swift
////  
////
////  Created by Nicolai Dam on 03/09/2023.
////
//
//import SwiftUI
//
//public struct EmailPicker: View {
//    
//    @State var enteredString = ""
//    @Binding var emails: [String]
//    @FocusState var textFieldFocused: Bool
//    
//    public init(enteredString: String = "", emails: Binding<[String]>) {
//        self.enteredString = enteredString
//        self._emails = emails
//    }
//    
//    public var body: some View {
//        content
//            .animation(.easeOut(duration: 0.5), value: emails)
//            .animation(.easeOut(duration: 0.5), value: enteredString)
//            .foregroundColor(.themeDarkGray)
//            .font(.montserratMedium, 14)
//    }
//}
//
//private extension EmailPicker {
//    var content: some View {
//        Section {
//            ForEach(self.$emails, id: \.self, editActions: .all) {
//                Text($0.wrappedValue.description)
//                    .padding(.vertical, 4)
//            }
//            HStack {
//                TextField(
//                    "New feedback question",
//                    text: $enteredString
//                )
//                .focused($textFieldFocused)
//                Button {
//                    withAnimation {
//                        emails.append(enteredString)
//                    }
//                    enteredString = ""
//                } label: {
//                    Image(systemName: "plus.circle.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30, alignment: .center)
//                        .scaledToFit()
//                }
//                .buttonStyle(PrimaryToolbarButtonStyle())
//                .disabled(enteredString.isEmpty)
//            }
//            .padding(.vertical, 4)
//        } header: {
//            HStack {
//                Text("Questions")
//                    .sectionHeaderStyle()
//                Spacer()
//                Button("Recommended") {
//                    hideKeyboard()
//                }
//                .buttonStyle(PrimaryToolbarButtonStyle())
//                
//            }
//        } footer: {
//            HStack {
//                Image(systemName: "info.circle")
//                    .resizable()
//                    .frame(width: 18, height: 18)
//                Text("Remember that the order of the questions can be important. ")
//                    .font(.montserratRegular, 12)
//            }
//            .foregroundColor(Color.themeDarkGray)
//        }
//    }
//}
//
//
//#Preview {
//    Form {
//        EmailPicker(
//            enteredString: "Hello",
//            emails: .constant(["nicolai@gmail.com"])
//        )
//    }
//}
//
