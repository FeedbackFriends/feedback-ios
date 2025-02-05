//
//  File.swift
//  
//
//  Created by Nicolai Dam on 07/12/2022.
//

import SwiftUI

public struct ErrorView: View {
    
    let message: String
    let tryAgainButtonTapped: (() -> Void)?
    @Binding var isLoading: Bool
    @State var viewDidLoad: Bool = false
    
    var exclamationmark: CGFloat {
        if viewDidLoad {
            return 40.0
        } else {
            return 35.0
        }
    }
    
    public init(message: String, isLoading: Binding<Bool>, tryAgainButtonTapped: (() -> Void)? = nil) {
        self.message = message
        self._isLoading = isLoading
        self.tryAgainButtonTapped = tryAgainButtonTapped
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "exclamationmark.circle.fill")
                .resizable()
                .frame(width: exclamationmark, height: exclamationmark)
                .foregroundColor(.themeRed)
            Text("Something went wrong 💩")
                .font(.montserratBold, 16)
                .foregroundColor(.themeDarkGray)
            Text(message)
                .font(.montserratRegular, 13)
                .foregroundColor(.themeDarkGray)
                .multilineTextAlignment(.center)
            if tryAgainButtonTapped != nil {
                Button {
                    self.tryAgainButtonTapped!()
                } label: {
                    Text("Try again")
                }
                .buttonStyle(PrimaryToolbarButtonStyle())
                .isLoading(isLoading)
                .disabled(isLoading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation {
                self.viewDidLoad = true
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        .padding(.horizontal, 50)
        
//        .offset(y: -50)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(
            message: "Message bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla",
            isLoading: .constant(false)
        ) { }
    }
}
