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

//func fontsURLs() -> [URL] {
//    let bundle = Bundle.module
//    var fileNames: [String] = []
//    for element in Font.FontName.allCases {
//        fileNames.append(element.rawValue)
//    }
//    return fileNames.map { bundle.url(forResource: $0, withExtension: "otf")! }
//}

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

private var didRegisterfonts = false
public func registerFonts() {
    guard !didRegisterfonts else { return }
    didRegisterfonts = true
    do {
        try fontsURLs().forEach { try UIFont.register(from: $0) }
    } catch {
        print(error)
    }
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
//    static let montserratBlack: UIFont = .init(name: "AcademySans-Bold", size: 28)!
    static func fontz(_ name: Font.FontName, _ size: CGFloat) -> UIFont {
        return UIFont(name: name.rawValue, size: size)!
    }
//    func fontYo(name: String, siz)
}
public extension View {
    func font(_ name: Font.FontName, _ size: CGFloat) -> some View {
        registerFonts()
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
