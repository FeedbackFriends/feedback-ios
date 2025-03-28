import Foundation
import SwiftUI
import UIKit

public struct Theme {
    public static let cornerRadius = 10.0
    public static let padding = 18.0
}

public extension Color {
    static let themeDarkGray = Color(#colorLiteral(red: 0.1529411765, green: 0.1647058824, blue: 0.2745098039, alpha: 1))
    static let themeDisabled = Color(#colorLiteral(red: 0.9359861503, green: 0.9446341087, blue: 0.9960437417, alpha: 1))
    static let themeHighligted = Color(#colorLiteral(red: 0.9359861503, green: 0.9446341087, blue: 0.9960437417, alpha: 1))
    static let themeSecondaryAction = Color(#colorLiteral(red: 0.9359861503, green: 0.9446341087, blue: 0.9960437417, alpha: 1))
    static let themeLightGray = Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1))
    static let themeLightGray2 = Color(#colorLiteral(red: 0.9122582078, green: 0.9092364907, blue: 0.9549568295, alpha: 1))
    static let themeWhite = Color(#colorLiteral(red: 0.9879724383, green: 1, blue: 1, alpha: 1))
    static let themeOrange = Color(#colorLiteral(red: 0.9829682708, green: 0.7350664735, blue: 0.381403774, alpha: 1))
    static let themeYellow = Color(#colorLiteral(red: 0.9850224853, green: 0.8622071147, blue: 0.3817542195, alpha: 1))
    static let themeRed = Color(#colorLiteral(red: 1, green: 0.44140625, blue: 0.4739984274, alpha: 1))
    static let themeGreen = Color(#colorLiteral(red: 0.5058823529, green: 0.8509803922, blue: 0.5921568627, alpha: 1))
    static let themePrimaryAction = Color(#colorLiteral(red: 0.1176470588, green: 0.662745098, blue: 0.4509803922, alpha: 1))
//    static let themePrimaryAction = Color(#colorLiteral(red: 0.01164593641, green: 0.5535881519, blue: 0.983589232, alpha: 1))
//    static let themePrimaryAction = Color(#colorLiteral(red: 0.3450980392, green: 0.5647058824, blue: 0.7333333333, alpha: 1))
//    static let themePrimaryAction = Color(#colorLiteral(red: 0.3137254902, green: 0.7843137255, blue: 0.4705882353, alpha: 1))
//    50c878
    static let themeBackground = Color(#colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9960784314, alpha: 1))
}

public extension UIColor {
    static var themeDarkGray: UIColor { return UIColor(.themeDarkGray) }
    static var themeLightGray: UIColor { return UIColor(.themeLightGray) }
    static var themeWhite: UIColor { return UIColor(.themeWhite) }
    static var themeBackground: UIColor { return UIColor(.themeBackground) }
}
