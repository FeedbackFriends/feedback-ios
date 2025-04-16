import Combine
import ComposableArchitecture
import Helpers
import DesignSystem
import SwiftUI
import Helpers
import Helpers

public struct ManagerEventsView: View {
    
    @Bindable var store: StoreOf<ManagerEvents>
    
    public init(store: StoreOf<ManagerEvents>) {
        self.store = store
    }
    
    public var body: some View {
        let eventDetailStore = $store.scope(state: \.destination?.eventDetail, action: \.destination.eventDetail)
        TabView(selection: $store.segmentedControl) {
            ScrollView {
                VStack {
                    TagFilterView(filter: $store.filterCollection)
                    if let managerEvents = store.session.managerData?.managerEvents {
                        managerEventsListView(
                            todayEvents: managerEvents.filter { $0.date.isToday },
                            comingUpEvents: managerEvents.filter { $0.date.isAfterToday },
                            previousEvents: managerEvents.filter { $0.date.isBeforeToday }
                        )
                    }
                }
            }
            .tag(SegmentedControlMenu.yourEvents)
            
            ScrollView {
                ParticipantEventsView(
                    store: store.scope(
                        state: \.participantEvents,
                        action: \.participantEvents
                    )
                )
            }
            .tag(SegmentedControlMenu.participating)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .lineSpacing(7)
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
        .overlay(alignment: .bottom) {
            CustomSegmentedPicker(selectedSegmentedControl: $store.segmentedControl.animation())
        }
        .background(Color.themeBackground)
        .foregroundStyle(Color.themeDarkGray.gradient)
        .navigationDestination(
            item: eventDetailStore
        ) { store in
            EventDetailFeatureView(store: store)
                .navigationTitle(store.navigationTitle)
        }
    }
}

extension ManagerEventsView {
    
    func managerEventsListView(
        todayEvents: [ManagerEvent],
        comingUpEvents: [ManagerEvent],
        previousEvents: [ManagerEvent]
    ) -> some View {
        LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
            if todayEvents.isEmpty && comingUpEvents.isEmpty && previousEvents.isEmpty {
                EmptyStateView(
                    message: "Create a new event by tapping the + button."
                )
            } else {
                if store.filterCollection.allEnabled {
                    if !todayEvents.isEmpty {
                        section(title: "Today") {
                            ForEach(todayEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                    }
                    if !comingUpEvents.isEmpty {
                        section(title: "Coming up") {
                            ForEach(comingUpEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                        
                    }
                    if !previousEvents.isEmpty {
                        section(title: "Previous") {
                            ForEach(previousEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                    }
                    
                } else {
                    if !todayEvents.isEmpty && store.filterCollection.todayEnabled {
                        section(title: "Today") {
                            ForEach(todayEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                    }
                    if !comingUpEvents.isEmpty && store.filterCollection.comingUpEnabled {
                        section(title: "Coming up") {
                            ForEach(comingUpEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                        
                    }
                    if !previousEvents.isEmpty && store.filterCollection.previousEnabled {
                        section(title: "Previous") {
                            ForEach(previousEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                    }
                }
            }
        }
        .padding(.bottom, 80)
        .padding(.horizontal, Theme.padding)
    }
    
    func managerEventListItem(_ event: ManagerEvent) -> some View {
        Button {
            store.send(.managerEventTap(event))
        } label: {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.title)
                            .font(.montserratSemiBold, 14)
                        Spacer()
                        if let eventSummary = event.feedbackSummary, eventSummary.unseenCount > 0 {
                            Text("\(eventSummary.unseenCount) new")
                                .font(.montserratBold, 10)
                                .padding(4)
                                .padding(.horizontal, 4)
                                .foregroundStyle(Color.themeWhite)
                                .background(Color.blue.opacity(0.5).gradient)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                        }
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(event.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.montserratRegular, 10)
                            Text("#\(event.pinCode)")
                                .font(.montserratSemiBold, 10)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.themeDarkGray.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.montserratRegular, 12)
                .foregroundColor(Color.themeDarkGray)
                .padding(.all, 10)
                if let feedbackSummary = event.feedbackSummary {
                    makeFeedbackPercentageBarView(feedback: feedbackSummary.segmentationStats)
                        .frame(height: 10)
                } else {
                    makeEmptyFeedbackSegmentationStatsView()
                }
            }
            .background(Color.themeWhite)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
        .buttonStyle(OpacityButtonStyle())
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

func section<Content: View>(title: String, content: () -> Content) -> some View {
    Section {
        content()
    } header: {
        HStack {
            Text(title)
                .font(.montserratBold, 16)
            Spacer()
        }
        .frame(height: 30)
        .background(Color.themeBackground)
    }
}


#Preview("Events") {
    NavigationStack {
        ManagerEventsView(
            store: .init(
                initialState: ManagerEvents.State(
                    session: .init(value: .mock())
                ),
                reducer: {
                    ManagerEvents()
                }
            )
        )
        .navigationTitle("Events")
    }
}

#Preview("Empty") {
    NavigationStack {
        ManagerEventsView(
            store: .init(
                initialState: ManagerEvents.State(
                    session: .init(value: .empty())
                ),
                reducer: {
                    ManagerEvents()
                }
            )
        )
        .navigationTitle("Events")
    }
}
