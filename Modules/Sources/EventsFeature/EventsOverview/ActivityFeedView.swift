import Helpers
import SwiftUI
import DesignSystem

struct ActivityView: View {
    let activityItems: [ActivityItems]
    let onTapActivityItem: (ActivityItems) -> ()
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            Group {
                if activityItems.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            title: "Empty",
                            message: "No new feedback or activity notifications have arrived yet. Once there’s an update, you’ll see it here."
                        )
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.themeBackground)
                } else {
                    List {
                        Section {
                            
                            ForEach(activityItems.sorted(by: { $0.date > $1.date })) { item in
                                Button {
                                    onTapActivityItem(item)
                                    dismiss()
                                } label: {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("New feedback on \(item.eventTitle)")
                                                .font(.montserratSemiBold, 14)
                                            Spacer()
                                            if !item.seenByManager  {
                                                Text("New")
                                                    .font(.montserratBold, 10)
                                                    .padding(4)
                                                    .padding(.horizontal, 4)
                                                    .foregroundStyle(Color.themeWhite)
                                                    .background(Color.blue.opacity(0.5).gradient)
                                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                                            }
                                        }
                                        Text("You have received feedback from \(item.newFeedbackCount) people on your event ‘\(item.eventTitle)’.")
                                            .font(.montserratRegular, 12)
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
                    SharedCloseButton { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ActivityView(
        activityItems: [],
        onTapActivityItem: { _ in }
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
        onTapActivityItem: { _ in }
    )
}
