import Combine
import ComposableArchitecture
import DependencyClients
import DesignSystem
import SwiftUI
import Helpers
import Helpers

public struct EventsOverviewView: View {
    
    @Bindable var store: StoreOf<EventsOverview>
    
    
    public init(store: StoreOf<EventsOverview>) {
        self.store = store
    }
    
    public var body: some View {
        let eventDetailStore = $store.scope(state: \.destination?.eventDetail, action: \.destination.eventDetail)
        let createEventStore = $store.scope(state: \.destination?.createEvent, action: \.destination.createEvent)
        let joinEventStore = $store.scope(state: \.destination?.joinEvent, action: \.destination.joinEvent)
        let infoStore = $store.scope(state: \.destination?.info, action: \.destination.info)
        content
            .animation(.default, value: store.session)
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .background(Color.themeBackground)
            .foregroundStyle(Color.themeDarkGray.gradient)
            .toolbar {
                switch store.session.userType {
                case .manager, .anonymoous:
                    createEventToolbar
                case .participant:
                    joinEventToolbar
                }
            }
            .navigationDestination(
                item: eventDetailStore
            ) { store in
                EventDetailFeatureView(store: store)
                    .navigationTitle(store.navigationTitle)
            }
            .sheet(item: createEventStore) { store in
                NavigationStack {
                    CreateEventView(store: store)
                }
            }
            .sheet(item: joinEventStore) { store in
                JoinEventView(store: store)
                    .presentationDetents([.height(270)])
            }
            .sheet(item: infoStore) { event in
                event.withState { event in
                    EventInfoView(
                        eventTitle: event.title,
                        eventAgenda: event.agenda,
                        ownerName: event.ownerInfo.name,
                        ownerEmail: event.ownerInfo.email,
                        ownerphoneNumber: event.ownerInfo.phoneNumber,
                        date: event.date
                    )
                }
            }
    }
}

extension EventsOverviewView {
    @ViewBuilder
    private var content: some View {
        switch store.session.userType {
        case let .manager(managerData: managerData, accountInfo: _):
            meetingManagerScrollView(
                managerEvent: managerData.managerEvents.elements,
                participantEvents: store.session.participantEvents.elements
            )
            .overlay(alignment: .bottom) {
                CustomSegmentedPicker(selectedSegmentedControl: $store.segmentedControl.animation())
            }
        case .participant(accountInfo: _), .anonymoous:
            ScrollView {
                VStack {
                    attendingListView(store.session.participantEvents.elements)
                }
                .padding(.bottom, 80)
                .menuIndicator(.hidden)
                .scrollContentBackground(Visibility.hidden)
                .background(Color.themeBackground)
            }
        }
    }
    
    var createEventToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Section {
                    Button {
                        store.send(.createEventButtonTap)
                    } label: {
                        Text("Create event")
                    }
                    
                }
                Section {
                    Button {
                        store.send(.joinEventButtonTap)
                    } label: {
                        Text("Join event")
                    }
                }
                
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundStyle(Color.themePrimaryAction.gradient)
            }
        }
    }
    
    var joinEventToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                store.send(.joinEventButtonTap)
            } label: {
                Text("Join")
            }
            .buttonStyle(PrimaryToolbarButtonStyle())
        }
    }
    
    func meetingManagerScrollView(managerEvent: [ManagerEvent], participantEvents: [ParticipantEvent]) -> some View {
        TabView(selection: $store.segmentedControl) {
            ScrollView {
                VStack {
                    TagFilterView(filter: $store.filterCollection)
                    managerEventsListView(
                        todayEvents: managerEvent.filter { $0.date.isToday },
                        comingUpEvents: managerEvent.filter { $0.date.isAfterToday },
                        previousEvents: managerEvent.filter { $0.date.isBeforeToday }
                    )
                }
            }
            .tag(SegmentedControlMenu.yourMeetings)
            
            ScrollView {
                attendingListView(participantEvents)
            }
            .tag(SegmentedControlMenu.attending)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .lineSpacing(7)
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
    }
}

// Own events
extension EventsOverviewView {
    
    func managerEventsListView(
        todayEvents: [ManagerEvent],
        comingUpEvents: [ManagerEvent],
        previousEvents: [ManagerEvent]
    ) -> some View {
        LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
            if todayEvents.isEmpty && comingUpEvents.isEmpty && previousEvents.isEmpty {
                EmptyStateView(
                    message: "You can create new meetings by tapping the + button in the upper right corner."
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
                        Text("\(event.date.formatted(date: .abbreviated, time: .omitted))")
                    }
                    HStack {
                        if event.newFeedbackForEvent > 0  {
                            Text("\(event.newFeedbackForEvent) new feedback")
                                .font(.montserratMedium, 12)
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
                if let feedback = event.feedbackSummary {
                    makeFeedbackPercentageBarView(feedback: feedback)
                        .frame(height: 10)
                } else {
                    makeEmptyFeedbackBarView()
                }
            }
            .background(Color.themeWhite)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
        .buttonStyle(OpacityButtonStyle())
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

//// Attending events
extension EventsOverviewView {
    func attendingListView(_ participantEvents: [ParticipantEvent]) -> some View {
        LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
            if participantEvents.isEmpty {
                EmptyStateView(
                    message: "Meetings you are added to will be visible here"
                )
            } else {
                let todayMeetings = participantEvents.filter { $0.date.isToday }
                let comingUpMeetings = participantEvents.filter { $0.date.isAfterToday }
                let pastMeetings = participantEvents.filter { $0.date.isBeforeToday }
                if !todayMeetings.isEmpty {
                    section(title: "Today") {
                        ForEach(todayMeetings) { event in
                            attendingListItem(event)
                        }
                    }
                }
                
                
                if !pastMeetings.isEmpty {
                    section(title: "Past week") {
                        ForEach(pastMeetings) { event in
                            attendingListItem(event)
                        }
                    }
                }
                
                if !comingUpMeetings.isEmpty {
                    section(title: "Coming up") {
                        ForEach(comingUpMeetings) { event in
                            attendingListItem(event)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 80)
        .padding(.horizontal, Theme.padding)
    }
    
    func attendingListItem(_ event: ParticipantEvent) -> some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(event.title)
                            .font(.montserratSemiBold, 14)
                        Spacer()
                        Text("\(event.date.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.montserratRegular, 12)
                .foregroundColor(Color.themeDarkGray)
                .padding(.all, 10)
                Divider()
                HStack(spacing: 12) {
                    
                    Button(action: {
                        store.send(.infoButtonTap(event))
                    }, label: {
                        HStack {
                            Image(systemName: "info.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            Text("Info")
                                .font(.montserratSemiBold, 14)
                        }
                        .foregroundStyle(Color.themeDarkGray)
                    })
                    .frame(maxWidth: .infinity, minHeight: 40)
                    Divider()
                    
                    if event.feedbackSubmitted {
                        Text("Submitted")
                            .font(.montserratSemiBold, 14)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundStyle(Color.themeDarkGray.gradient.opacity(0.5))
                    } else {
                        let startFeedbackInFlight = store.startFeedbackInFlight == event.pinCode
                        Button("Start") {
                            store.send(.startFeedbackButtonTap(pinCode: event.pinCode))
                        }
                        .disabled(startFeedbackInFlight)
                        .buttonStyle(PrimaryToolbarButtonStyle())
                        .isLoading(startFeedbackInFlight)
                        .frame(maxWidth: .infinity, minHeight: 40)
                    }
                }
                
            }
            .font(.montserratBold, 14)
            .foregroundStyle(Color.themeWhite)
            .background(Color.themeWhite)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
    }
}

extension EventsOverviewView {
    private func section<Content: View>(title: String, content: () -> Content) -> some View {
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
}

#Preview("Your events") {
    NavigationStack {
        EventsOverviewView(
            store: .init(
                initialState: EventsOverview.State(
                    session: .init(value: .mock()),
                    segmentedControl: .yourMeetings
                ),
                reducer: {
                    EventsOverview()
                }
            )
        )
        .navigationTitle("Events")
    }
}

#Preview("Attending") {
    NavigationStack {
        EventsOverviewView(
            store: .init(
                initialState: EventsOverview.State(session: .init(value: .mock()), segmentedControl: .attending),
                reducer: {
                    EventsOverview()
                }
            )
        )
        .navigationTitle("Events")
    }
}
