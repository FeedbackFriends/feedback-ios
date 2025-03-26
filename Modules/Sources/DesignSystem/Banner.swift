import SwiftUI

public enum BannerState: Equatable {
    case offline(String)
    case serverError(String)
}

public extension View {
    
    /// Banner that shows offline or server error 'toast' style banner
    /// - Parameter enum: field controlling banner state
    /// - Returns: modified view
    func banner(unwrapping enum: BannerState?) -> some View {
        ZStack {
            self
            if let `enum` = `enum` {
                
                switch `enum` {
                case let .serverError(msg):
                    makeBanner(message: msg, color: .red)
                    
                case let .offline(msg):
                    makeBanner(message: msg, color: .orange)
                }
            }
        }
        .animation(.linear(duration: 1), value: `enum`)
    }
    
    func makeBanner(
        message: String,
        color: Color
    ) -> some View {
        VStack {
            Text(message)
                .font(.montserratRegular, 14)
                .padding(.horizontal, 50)
                .frame(minHeight: 54)
                .background(Color.white)
                .foregroundColor(Color.themeDarkGray)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.08), radius: 2)
                .padding(.horizontal, 16)
                .padding(.top, 12)
            Spacer()
            
        }.zIndex(1)
            .transition(
                .move(edge: .top)
            )
    }
}
