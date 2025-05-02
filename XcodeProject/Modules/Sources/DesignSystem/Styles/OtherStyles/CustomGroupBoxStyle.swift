import SwiftUI

public struct CustomGroupBoxStyle: GroupBoxStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .background(Color.themeWhite)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}
