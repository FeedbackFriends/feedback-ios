import Foundation
import SwiftUI
import UIKit

extension UIFont {
	static func register(from url: URL) throws {
		var error: Unmanaged<CFError>?
		let success = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
		guard success else {
			throw error!.takeUnretainedValue()
		}
	}
}

class FontRegistration {
	private var didRegisterFonts = false
	
	func registerFontsIfNeeded() {
		guard !didRegisterFonts else { return }
		didRegisterFonts = true
		do {
			try fontsURLs().forEach { try UIFont.register(from: $0) }
		} catch {
			fatalError("Failed to register fonts: \(error)")
		}
	}
}

func fontsURLs() -> [URL] {
	Font.FontName
		.allCases
		.map(\.rawValue)
		.map {
			Bundle.module.url(forResource: $0, withExtension: "otf")
		}.compactMap { $0 }
}

let fontRegistration = FontRegistration()

public extension UIFont {
	static func font(_ name: Font.FontName, _ size: CGFloat) -> UIFont {
		fontRegistration.registerFontsIfNeeded()
		return UIFont(name: name.rawValue, size: size)!
	}
}

public extension View {
	func font(_ name: Font.FontName, _ size: CGFloat) -> some View {
		fontRegistration.registerFontsIfNeeded()
		return font(.custom(name.rawValue, size: size))
	}
}

#Preview {
	ScrollView {
		VStack {
			ForEach(Font.FontName.allCases) {
				Text("\($0)" as String).font($0, 12)
			}
		}
		.environment(\.sizeCategory, .accessibilityExtraExtraLarge)
	}
}
