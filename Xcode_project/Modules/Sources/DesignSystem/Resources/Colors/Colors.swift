import Foundation
import SwiftUI
import UIKit

public struct Theme {
	public static let cornerRadius = 10.0
	public static let padding = 18.0
}

public extension Color {
	static let themeDarkGray = Color("themeDarkGray", bundle: Bundle.module)
	static let themeDisabled = Color("themeDisabled", bundle: Bundle.module)
	static let themeHighligted = Color("themeHighligted", bundle: Bundle.module)
	static let themeSecondaryAction = Color("themeSecondaryAction", bundle: Bundle.module)
	static let themeLightGray = Color("themeLightGray", bundle: Bundle.module)
	static let themeLightGray2 = Color("themeLightGray2", bundle: Bundle.module)
	static let themeWhite = Color("themeWhite", bundle: Bundle.module)
	static let themeOrange = Color("themeOrange", bundle: Bundle.module)
	static let themeYellow = Color("themeYellow", bundle: Bundle.module)
	static let themeRed = Color("themeRed", bundle: Bundle.module)
	static let themeGreen = Color("themeGreen", bundle: Bundle.module)
	static let themePrimaryAction = Color("primaryAction", bundle: Bundle.module)
	static let themeOnPrimaryAction = Color("onPrimaryAction", bundle: Bundle.module)
	static let themeBackground = Color("background", bundle: Bundle.module)
	static let themeBackgroundInverted = Color("backgroundInverted", bundle: Bundle.module)
	static let themeSurface = Color("surface", bundle: Bundle.module)
	static let themeText = Color("text", bundle: Bundle.module)
}

public extension UIColor {
	static var themeDarkGray: UIColor { return UIColor(.themeDarkGray) }
	static var themeLightGray: UIColor { return UIColor(.themeLightGray) }
	static var themeWhite: UIColor { return UIColor(.themeWhite) }
	static var themeBackground: UIColor { return UIColor(.themeBackground) }
}
