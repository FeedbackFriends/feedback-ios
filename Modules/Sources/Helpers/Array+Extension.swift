import Foundation
import IdentifiedCollections

public extension Array where Element: Identifiable {
    var identifiedArray: IdentifiedArrayOf<Element> {
        IdentifiedArray(uniqueElements: self)
    }
}
