import Helpers
import SwiftUI
import DesignSystem

public struct ActivityView: View {
    let activityItems: [ActivityItems]
    let navigateToManagerEvent: (ActivityItems) -> ()
    @Environment(\.dismiss) var dismiss
    
    public init(activityItems: [ActivityItems], navigateToManagerEvent: @escaping (ActivityItems) -> Void) {
        self.activityItems = activityItems
        self.navigateToManagerEvent = navigateToManagerEvent
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if activityItems.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            title: "Empty",
                            message: "Nothing to show here yet. Once there’s an update, you’ll see it here."
                        )
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.themeBackground)
                } else {
                    List {
                        Section {
                            
                            ForEach(activityItems.sorted(by: { $0.date > $1.date })) { item in
                                Button {
                                    navigateToManagerEvent(item)
                                    dismiss()
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text("Feedback on \(item.eventTitle)")
                                            .font(.montserratSemiBold, 14)
                                        Text("You have received \(item.newFeedbackCount) new feedback on ‘\(item.eventTitle)’.")
                                            .font(.montserratRegular, 12)
                                        HStack {
                                            if !item.seenByManager {
                                                Text("New")
                                                    .font(.montserratBold, 8)
                                                    .padding(2)
                                                    .padding(.horizontal, 4)
                                                    .foregroundStyle(Color.themeWhite)
                                                    .background(Color.blue.opacity(0.5).gradient)
                                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                                            }
                                            Text(item.date.timeAgo())
                                                .foregroundStyle(Color.gray)
                                                .font(.montserratRegular, 10)
                                            Spacer()
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
            .foregroundStyle(Color.themeDarkGray)
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SharedCloseButtonView { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ActivityView(
        activityItems: [],
        navigateToManagerEvent: { _ in }
    )
}
#Preview {
    ActivityView(
        activityItems: [
            .init(
                id: UUID(),
                date: Date(),
                eventTitle: "title1",
                eventId: UUID(),
                newFeedbackCount: 5,
                seenByManager: false
            ),
            .init(
                id: UUID(),
                date: Date(),
                eventTitle: "title2",
                eventId: UUID(),
                newFeedbackCount: 5,
                seenByManager: true
            )
        ],
        navigateToManagerEvent: { _ in }
    )
}
