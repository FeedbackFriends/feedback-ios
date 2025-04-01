import Combine
import ComposableArchitecture
import Helpers
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
        let activityStore = $store.scope(state: \.destination?.activity, action: \.destination.activity)
        let startFeedbackConfirmationStore = $store.scope(
            state: \.destination?.startFeedbackConfirmation,
            action: \.destination.startFeedbackConfirmation
        )
        content
            .animation(.default, value: store.session)
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .background(Color.themeBackground)
            .foregroundStyle(Color.themeDarkGray.gradient)
            .toolbar {
                switch store.session.userType {
                case .manager(let managerData,_):
                    activityToolbarItem(managerData.activity.unseenTotal)
                    createEventToolbarItem
                    case .anonymoous:
                    createEventToolbarItem
                case .participant:
                    joinEventToolbarItem
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
                    .presentationDetents([.medium, .large])
                }
            }
            .sheet(item: activityStore) { activityItems in
                activityItems.withState { activityItems in
                    ActivityView(
                        activityItems: activityItems,
                        onTapActivityItem: {
                            store.send(.onTapActivityItem($0))
                        }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            .sheet(item: startFeedbackConfirmationStore) { pinCode in
                pinCode.withState { pinCode in
                    StartFeedbackConfirmationView(startFeedback: {
                        store.send(.confirmedToStartFeedback(pinCode: pinCode))
                    })
                    .presentationDetents([.height(300)])
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
    
    var createEventToolbarItem: some ToolbarContent {
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
    
    var joinEventToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                store.send(.joinEventButtonTap)
            } label: {
                Text("Join")
            }
            .buttonStyle(PrimaryToolbarButtonStyle())
        }
    }
    
    func activityToolbarItem(_ count: Int) -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                store.send(.activityButtonTap)
            } label: {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(IconToolbarStyle())
            .overlay(alignment: .bottomTrailing) { 
                if count > 0 {
                    Text(count.description)
                        .foregroundStyle(Color.white)
                        .font(.montserratSemiBold, 10)
                        .padding(6)
                        .background(Circle().foregroundStyle(Color.themeRed))
                        .offset(x: 7, y: 7)
                }
            }
        }
    }
    
    func meetingManagerScrollView(
        managerEvent: [ManagerEvent],
        participantEvents: [ParticipantEvent]
    ) -> some View {
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
                    .scrollPosition(id: $store.attendingEventsScrollPosition)
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

//// Attending events
extension EventsOverviewView {
    func attendingListView(_ participantEvents: [ParticipantEvent]) -> some View {
        LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
            if participantEvents.isEmpty {
                EmptyStateView(
                    message: "Joined events will be visible here"
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
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(event.title)
                            .font(.montserratSemiBold, 14)
                        Spacer()
                        if event.recentlyJoined {
                            Text("Recently joined")
                                .font(.montserratBold, 10)
                                .padding(4)
                                .padding(.horizontal, 4)
                                .foregroundStyle(Color.themeWhite)
                                .background(Color.blue.opacity(0.5).gradient)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.montserratRegular, 12)
                .foregroundColor(Color.themeDarkGray)
                Divider()
                HStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(event.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.montserratRegular, 10)
                            Text("#\(event.pinCode)")
                                .font(.montserratSemiBold, 10)
                        }
                        Spacer()
                    }
                    .foregroundStyle(Color.themeDarkGray)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    Divider()
                    if event.feedbackSubmitted {
                        Text("Submitted")
                            .font(.montserratSemiBold, 14)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundStyle(Color.themeDarkGray.gradient.opacity(0.5))
                    } else {
                        let startFeedbackPincodeInFlight = store.startFeedbackPincodeInFlight == event.pinCode
                        Button("Start") {
                            store.send(.startFeedbackButtonTap(pinCode: event.pinCode))
                        }
                        .disabled(startFeedbackPincodeInFlight)
                        .buttonStyle(PrimaryToolbarButtonStyle())
                        .isLoading(startFeedbackPincodeInFlight)
                        .frame(maxWidth: .infinity, minHeight: 40)
                    }
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.montserratBold, 14)
            .foregroundStyle(Color.themeWhite)
            .padding(.all, 10)
        }
        .background(Color.themeWhite)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            store.send(.infoButtonTap(event))
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
