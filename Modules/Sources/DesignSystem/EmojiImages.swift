import APIClient
import Foundation
import SwiftUI

public extension Emoji {
    var icon: Image {
        switch self {
        case .verySad:
            Image.verySad
        case .sad:
            Image.sad
        case .happy:
            Image.happy
        case .veryHappy:
            Image.veryHappy
        }
    }
}
