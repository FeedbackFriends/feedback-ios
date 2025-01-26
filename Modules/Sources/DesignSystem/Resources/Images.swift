import Foundation
import SwiftUI

public extension Image {
    static let iconGoogle = Image("icon_google", bundle: Bundle.module)
    static let iconFacebook = Image("icon_facebook", bundle: Bundle.module)
    static let iconApple = Image(systemName: "applelogo")
    static let iconMicrosoft = Image("icon_Microsoft", bundle: Bundle.module)
#warning("Chanhge to happy, sad etc")
    static let verySad = Image("verySad", bundle: Bundle.module)
    static let sad = Image("sad", bundle: Bundle.module)
    static let happy = Image("happy", bundle: Bundle.module)
    static let veryHappy = Image("veryHappy", bundle: Bundle.module)
}

