import ComposableArchitecture
import Domain
import SwiftUI
import DesignSystem

@Reducer
public struct DraftEvents: Sendable {
    
    @Reducer
    public enum Destination {
        case editEvent(EditEvent)
        case deleteConfirmation(DeleteConfirmation)
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?
        @Shared var session: Session

        var draftEvents: [ManagerEvent] {
            session.managerData?.draftEvents ?? []
        }

        public init(
            destination: Destination.State? = nil,
            session: Shared<Session>
        ) {
            self.destination = destination
            self._session = session
        }
    }

    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case draftButtonTap(ManagerEvent)
        case deleteButtonTap(ManagerEvent)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none

            case .draftButtonTap(let event):
                let recentlyUsedQuestions = if let managerData = state.session.managerData {
                    Set<RecentlyUsedQuestions>(managerData.recentlyUsedQuestions)
                } else {
                    Set<RecentlyUsedQuestions>()
                }
                state.destination = .editEvent(
                    EditEvent.State(
                        eventForm: EventForm.State(
                            eventInput: EventInput(event),
                            participants: event.participants,
                            showsParticipants: true,
                            shouldOpenKeyboardOnAppear: false,
                            recentlyUsedQuestions: recentlyUsedQuestions,
                            successOverlayMessage: "Session edited"
                        ),
                        eventId: event.id,
                        recentlyUsedQuestions: recentlyUsedQuestions
                    )
                )
                return .none

            case .deleteButtonTap(let event):
                state.destination = .deleteConfirmation(.init(eventId: event.id))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

public struct DraftEventsView: View {
    @Bindable var store: StoreOf<DraftEvents>
    @Environment(\.dismiss) var dismiss
    
    public init(
        store: StoreOf<DraftEvents>
    ) {
        self.store = store
    }
    
    public var body: some View {
        let deleteConfirmationStore = $store.scope(
            state: \.destination?.deleteConfirmation,
            action: \.destination.deleteConfirmation
        )
        let editEventStore = $store.scope(state: \.destination?.editEvent, action: \.destination.editEvent)
        let activeDraftEvents = store.draftEvents.filter { !$0.date.isBeforeToday }
        let archivedDraftEvents = store.draftEvents.filter { $0.date.isBeforeToday }
        NavigationStack {
            Group {
                if activeDraftEvents.isEmpty && archivedDraftEvents.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            title: "Nothing to show here yet.",
                            message: "Once there’s an update, you’ll see it here."
                        )
                        .frame(maxWidth: Constants.maxWidthForLargeDevices)
                        .padding(.horizontal, Theme.padding)
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    List {
                        if !activeDraftEvents.isEmpty {
                            Section {
                                ForEach(activeDraftEvents.sorted(by: { $0.date > $1.date })) { item in
                                    draftEventListRow(item, isArchived: false)
                                }
                            }
                        }
                        if !archivedDraftEvents.isEmpty {
                            Section {
                                ForEach(archivedDraftEvents.sorted(by: { $0.date > $1.date })) { item in
                                    draftEventListRow(item, isArchived: true)
                                }
                            } header: {
                                Text("Archived")
                                    .font(.montserratSemiBold, 12)
                                    .foregroundStyle(Color.themeTextSecondary)
                                    .textCase(nil)
                                    .padding(.leading, Theme.padding)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .foregroundStyle(Color.themeText)
            .navigationTitle("Drafts")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
            .navigationDestination(item: editEventStore) { store in
                EditEventView(store: store)
            }
            .sheet(item: deleteConfirmationStore) { store in
                DeleteConfirmationView(store: store)
                    .presentationDetents([.height(300)])
            }
            .background(Color.themeBackground)
        }
    }
}

private extension DraftEventsView {
    struct ProviderBadgeConfig {
        let image: Image
        let tint: Color?
        let label: String
    }

    func draftEventRow(_ item: ManagerEvent, isArchived: Bool) -> some View {
        HStack(spacing: 12) {
            providerBadge(item.calendarProvider)
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.montserratSemiBold, 14)
                    .foregroundStyle(Color.themeText)
                HStack(spacing: 8) {
                    Text(item.formattedDate)
                        .font(.montserratRegular, 11)
                        .foregroundStyle(Color.themeTextSecondary)
                    if let providerName = providerDisplayName(item.calendarProvider) {
                        Text(providerName)
                            .font(.montserratSemiBold, 11)
                            .foregroundStyle(Color.themeTextSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.themeSurface)
                            .clipShape(Capsule())
                    }
                    if isArchived {
                        Text("Archived")
                            .font(.montserratSemiBold, 11)
                            .foregroundStyle(Color.themeTextSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .stroke(Color.themeTextSecondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            Spacer()
            
                Image.chevronRight
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.themeText.opacity(0.8))
            
        }
        .padding(.vertical, 12)
        .padding(.leading, Theme.padding)
        .padding(.trailing, Theme.padding + 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(Color.themeSurface)
        )
        .lightShadow()
    }

    @ViewBuilder
    func draftEventListRow(_ item: ManagerEvent, isArchived: Bool) -> some View {
        let rowContent = draftEventRow(item, isArchived: isArchived)
        ZStack(alignment: .trailing) {
            Button {
                store.send(.draftButtonTap(item))
            } label: {
                rowContent
            }
            .buttonStyle(OpacityButtonStyle())
            draftEventMenu(item)
                .padding(.trailing, Theme.padding)
        }
        .listRowInsets(EdgeInsets(top: 6, leading: Theme.padding, bottom: 6, trailing: Theme.padding))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    func draftEventMenu(_ item: ManagerEvent) -> some View {
        Menu {
            Button {
                store.send(.draftButtonTap(item))
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                store.send(.deleteButtonTap(item))
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.themeTextSecondary)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
                .rotationEffect(.degrees(90))
        }
    }
    
    func providerBadge(_ provider: CalendarProvider?) -> some View {
        let config = providerBadgeConfig(provider)
        return ZStack {
            if #available(iOS 26.0, *) {
                Circle()
                    .fill(Color.clear)
                    .glassEffect()
            } else {
                Circle()
                    .fill(.ultraThinMaterial)
            }
            if let tint = config.tint {
                config.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(tint)
            } else {
                config.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
        }
        .frame(width: 34, height: 34)
        .overlay(Circle().stroke((config.tint ?? Color.themeTextSecondary).opacity(0.2), lineWidth: 1))
        .accessibilityLabel(Text(config.label))
    }
    
    func providerDisplayName(_ provider: CalendarProvider?) -> String? {
        guard let provider else { return nil }
        switch provider {
        case .APPLE:
            return "Apple"
        case .GOOGLE:
            return "Google"
        case .MICROSOFT:
            return "Microsoft"
        case .ZOOM:
            return "Zoom"
        }
    }
    
    func providerBadgeConfig(_ provider: CalendarProvider?) -> ProviderBadgeConfig {
        guard let provider else {
            return ProviderBadgeConfig(
                image: Image.calendar,
                tint: Color.themeTextSecondary,
                label: "Calendar"
            )
        }
        switch provider {
        case .APPLE:
            return ProviderBadgeConfig(image: Image.iconApple, tint: Color.themeText, label: "Apple Calendar")
        case .GOOGLE:
            return ProviderBadgeConfig(image: Image.iconGoogle, tint: nil, label: "Google Calendar")
        case .MICROSOFT:
            return ProviderBadgeConfig(image: Image.iconMicrosoft, tint: nil, label: "Microsoft Outlook")
        case .ZOOM:
            return ProviderBadgeConfig(image: Image(systemName: "video.fill"), tint: Color.themeBlue, label: "Zoom")
        }
    }
}

extension DraftEvents.Destination.State: Equatable, Sendable {}

#Preview {
    DraftEventsView(
        store: .init(
            initialState: DraftEvents.State(
                session: .init(value: .empty())
            ),
            reducer: {
                DraftEvents()
            }
        )
    )
}

#Preview {
    var session = Session.empty()
    session.managerData?.draftEvents = [
        ManagerEvent.mock()
    ]
    return DraftEventsView(
        store: .init(
            initialState: DraftEvents.State(
                session: .init(value: session)
            ),
            reducer: {
                DraftEvents()
            }
        )
    )
}
