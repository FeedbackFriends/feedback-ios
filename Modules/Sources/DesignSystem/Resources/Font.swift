import Foundation
import SwiftUI
import UIKit

func fontsURLs() -> [URL] {
    Font.FontName
        .allCases
        .map(\.rawValue)
        .map {
            Bundle.module.url(forResource: $0, withExtension: "otf")
        }.compactMap {
            $0
        }
}

extension UIFont {
    static func register(from url: URL) throws {
        guard let fontDataProvider = CGDataProvider(url: url as CFURL) else {
            fatalError()
        }
        let font = CGFont(fontDataProvider)!
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(font, &error) else {
            throw error!.takeUnretainedValue()
        }
    }
}

actor FontRegistration {
    private var didRegisterFonts = false
    
    func registerFontsIfNeeded() async {
        guard !didRegisterFonts else { return }
        didRegisterFonts = true
        do {
            try fontsURLs().forEach { try UIFont.register(from: $0) }
        } catch {
            print(error)
        }
    }
}

private let fontRegistration = FontRegistration()

public func registerFonts() async {
    await fontRegistration.registerFontsIfNeeded()
}

public extension Font {
    enum FontName: String, CaseIterable, Identifiable {
        public var id: String {
            "\(self)"
        }
        case montserratBlack = "Montserrat-Black"
        case montserratBold = "Montserrat-Bold"
        case montserratExtraBold = "Montserrat-ExtraBold"
        case montserratExtraLight = "Montserrat-ExtraLight"
        case montserratItalic = "Montserrat-Italic"
        case montserratMedium = "Montserrat-Medium"
        case montserratRegular = "Montserrat-Regular"
        case montserratSemiBold = "Montserrat-SemiBold"
        case montserratThin = "Montserrat-Thin"
    }
}

public extension UIFont {
    static func fontz(_ name: Font.FontName, _ size: CGFloat) -> UIFont {
        return UIFont(name: name.rawValue, size: size)!
    }
}
public extension View {
    func font(_ name: Font.FontName, _ size: CGFloat) -> some View {
        return font(.custom(name.rawValue, size: size))
    }
}
struct FontTestView: View, PreviewProvider {
    var body: some View {
        VStack {
            ForEach(Font.FontName.allCases) {
                Text("\($0)" as String).font($0,12)
            }
        }
    }

    static var previews: some View {
        ScrollView {
            FontTestView()
            FontTestView()
                .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
        }
    }
}
