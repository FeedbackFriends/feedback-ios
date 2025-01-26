import SwiftUI
import Lottie

public struct LottieView: UIViewRepresentable {
    
    let lottieFile: String
    let loopMode: Bool
    
    public init(lottieFile: String, loopMode: Bool = false) {
        self.lottieFile = lottieFile
        self.loopMode = loopMode
    }
    let animationView = LottieAnimationView()
    
    public func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        animationView.animation = LottieAnimation.named(lottieFile, bundle: .module)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode ? .loop : .playOnce
        animationView.animationSpeed = 0.5
        animationView.play()
        
        view.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        LottieView(lottieFile: "need-location")
            .frame(width: 300, height: 300)
    }
}
