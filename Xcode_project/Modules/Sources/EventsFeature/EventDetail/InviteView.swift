import SwiftUI
import DesignSystem
import UIKit
import Domain
import ComposableArchitecture

@Reducer
public struct InviteFeature: Sendable {
    
    @ObservableState
    public struct State: Equatable, Sendable {
        var eventInput: EventInput
        let eventId: UUID
        let inviteLink: String
        let shareText: String
        let participants: [ParticipantSummary]
        var attendeeEmailInput: String
        var saveRequestInFlight = false
        var showSuccessOverlay = false
        let initialInvitedEmails: [String]
        @Presents var alert: AlertState<Never>?
        
        public init(event: ManagerEvent, inviteLink: String, shareText: String) {
            self.eventInput = EventInput(event)
            self.eventId = event.id
            self.inviteLink = inviteLink
            self.shareText = shareText
            self.participants = event.participants
            self.attendeeEmailInput = ""
            self.initialInvitedEmails = event.invitedEmails
        }
        
        var hasChanges: Bool {
            let trimmedInput = attendeeEmailInput.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedInput.isEmpty {
                return true
            }
            let initialSet = Set(initialInvitedEmails.map { $0.lowercased() })
            let currentSet = Set(eventInput.invitedEmails.map { $0.lowercased() })
            return initialSet != currentSet
        }
        
        var saveButtonDisabled: Bool {
            saveRequestInFlight || showSuccessOverlay || !hasChanges
        }
        
        mutating func commitAttendeeEmailInput() {
            let trimmedInput = attendeeEmailInput.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedInput.isEmpty else { return }
            let inputEmails = trimmedInput.split(whereSeparator: { $0 == "," || $0 == ";" || $0.isWhitespace })
            var normalizedExisting = Set(eventInput.invitedEmails.map { $0.lowercased() })
            var added = false
            for rawEmail in inputEmails {
                let trimmedEmail = rawEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedEmail.isEmpty else { continue }
                let normalizedEmail = trimmedEmail.lowercased()
                guard !normalizedExisting.contains(normalizedEmail) else { continue }
                eventInput.invitedEmails.append(trimmedEmail)
                normalizedExisting.insert(normalizedEmail)
                added = true
            }
            if added {
                attendeeEmailInput = ""
            }
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addAttendeeEmailButtonTap
        case removeAttendeeEmailButtonTap(String)
        case saveButtonTap
        case saveResponse
        case presentError(Error)
        case closeButtonTap
        case alert(PresentationAction<Never>)
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .addAttendeeEmailButtonTap:
                state.commitAttendeeEmailInput()
                return .none
                
            case .removeAttendeeEmailButtonTap(let email):
                state.eventInput.invitedEmails.removeAll { $0.caseInsensitiveCompare(email) == .orderedSame }
                return .none
                
            case .saveButtonTap:
                state.commitAttendeeEmailInput()
                state.saveRequestInFlight = true
                return .run { [state] send in
                    do {
                        _ = try await apiClient.updateEvent(state.eventInput, state.eventId)
                        await send(.saveResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .presentError(let error):
                state.saveRequestInFlight = false
                state.alert = .init(error: error)
                return .none
                
            case .saveResponse:
                state.saveRequestInFlight = false
                state.showSuccessOverlay = true
                return .none
                
            case .closeButtonTap:
                return .run { _ in
                    await dismiss()
                }
                
            case .alert:
                return .none
            }
        }
    }
}

struct InviteView: View {
    @Bindable var store: StoreOf<InviteFeature>
    @State private var shareSheet: String?
    
    init(store: StoreOf<InviteFeature>) {
        self.store = store
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    infoSection
                    linkSection
                    participantsSection
                    invitedSection
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 8)
                .padding(.bottom, 80)
                .navigationTitle("Invite")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        CloseButtonView {
                            store.send(.closeButtonTap)
                        }
                    }
                }
                .foregroundStyle(Color.themeText)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Color.themeBackground)
            .safeAreaInset(edge: .bottom) {
                saveBar
            }
            .sheet(item: $shareSheet, id: \.self) { shareContent in
                ShareSheet(activityItems: [shareContent])
                    .presentationDetents([.medium, .large])
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .successOverlay(
            message: "Invites sent",
            show: $store.showSuccessOverlay
        )
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Invite people to your session")
                .font(.montserratSemiBold, 18)
            Text("Participants already joined in the app. Invited people receive an email invite.")
                .font(.montserratRegular, 12)
                .foregroundStyle(Color.themeTextSecondary)
        }
    }
    
    private var linkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Invite link")
                .sectionHeaderStyle()
                .padding(.leading, 12)
            sectionCard {
                Text(store.inviteLink)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.themeSurfaceSecondary)
                    .foregroundStyle(Color.themeText)
                    .cornerRadius(Theme.cornerRadius)
                    .font(.montserratMedium, 14)
                    .textSelection(.enabled)
                    .overlay(copyButton, alignment: .trailing)
                Button {
                    shareSheet = store.shareText
                } label: {
                    HStack(spacing: 8) {
                        Image.squareAndArrowUp
                            .font(.system(size: 14, weight: .semibold))
                        Text("Share invite")
                    }
                }
                .buttonStyle(LargeBoxButtonStyle(style: .secondary))
            }
        }
    }
    
    private var copyButton: some View {
        Button {
            shareSheet = store.inviteLink
        } label: {
            HStack {
                Image.documentOnDocument
                    .font(.system(size: 16, weight: .regular))
            }
            .padding(.trailing, 12)
        }
        .buttonStyle(SecondaryTextButtonStyle())
        .frame(maxHeight: .infinity)
    }
    
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Participants", count: store.participants.count)
            sectionCard {
                if store.participants.isEmpty {
                    emptyStateText("No participants yet.")
                } else {
                    participantList
                }
            }
        }
    }
    
    private var invitedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Invited (pending)", count: store.eventInput.invitedEmails.count)
            sectionCard {
                inviteInputRow
                if store.eventInput.invitedEmails.isEmpty {
                    emptyStateText("Add emails to send invites.")
                } else {
                    invitedList
                }
            }
        }
    }
    
    private var participantList: some View {
        VStack(spacing: 12) {
            ForEach(Array(store.participants.enumerated()), id: \.offset) { index, participant in
                participantRow(participant)
                if index < store.participants.count - 1 {
                    Divider()
                }
            }
        }
    }
    
    private var invitedList: some View {
        VStack(spacing: 12) {
            ForEach(Array(store.eventInput.invitedEmails.enumerated()), id: \.offset) { index, email in
                pendingInviteRow(email)
                if index < store.eventInput.invitedEmails.count - 1 {
                    Divider()
                }
            }
        }
    }
    
    private func participantRow(_ participant: ParticipantSummary) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.themeSurfaceSecondary)
                    .frame(width: 36, height: 36)
                Text(initials(for: participant))
                    .font(.montserratSemiBold, 12)
                    .foregroundStyle(Color.themeText)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(primaryText(for: participant))
                    .font(.montserratMedium, 14)
                    .foregroundStyle(Color.themeText)
                if let secondary = secondaryText(for: participant) {
                    Text(secondary)
                        .font(.montserratRegular, 12)
                        .foregroundStyle(Color.themeTextSecondary)
                }
            }
            Spacer()
            Image.checkmarkCircleFill
                .foregroundStyle(Color.themeSuccess)
                .font(.system(size: 16))
                .accessibilityHidden(true)
        }
    }
    
    private func pendingInviteRow(_ email: String) -> some View {
        HStack(spacing: 12) {
            Text(email)
                .font(.montserratRegular, 13)
                .foregroundStyle(Color.themeTextSecondary)
            Spacer()
            Button {
                store.send(.removeAttendeeEmailButtonTap(email))
            } label: {
                Image.xmarkCircleFill
                    .foregroundStyle(Color.themeTextSecondary)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Remove \(email)"))
        }
    }
    
    private var inviteInputRow: some View {
        HStack(spacing: 8) {
            TextField("Add attendee email", text: $store.attendeeEmailInput)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit {
                    store.send(.addAttendeeEmailButtonTap)
                }
            Button("Add") {
                store.send(.addAttendeeEmailButtonTap)
            }
            .buttonStyle(SecondaryTextButtonStyle())
            .disabled(store.attendeeEmailInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(12)
        .background(Color.themeSurfaceSecondary)
        .cornerRadius(Theme.cornerRadius)
    }
    
    private var saveBar: some View {
        VStack(spacing: 12) {
            Button("Send invites") {
                store.send(.saveButtonTap)
            }
            .buttonStyle(LargeButtonStyle())
            .isLoading(store.saveRequestInFlight)
            .disabled(store.saveButtonDisabled)
        }
        .padding(.horizontal, Theme.padding)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background {
            Color.clear
                .glassEffect(in: .rect(cornerRadius: 24))
                .ignoresSafeArea(edges: .bottom)
        }
    }
    
    private func sectionHeader(title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .sectionHeaderStyle()
            Spacer()
            Text("\(count)")
                .font(.montserratMedium, 12)
                .foregroundStyle(Color.themeTextSecondary)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.themeSurfaceSecondary)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
    }
    
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12, content: content)
            .padding(16)
            .background(Color.themeSurface)
            .cornerRadius(Theme.cornerRadius)
            .lightShadow(opacity: 0.06)
    }
    
    private func emptyStateText(_ text: String) -> some View {
        Text(text)
            .font(.montserratRegular, 12)
            .foregroundStyle(Color.themeTextSecondary)
    }
    
    private func initials(for participant: ParticipantSummary) -> String {
        let primary = primaryText(for: participant)
        return String(primary.prefix(1)).uppercased()
    }
    
    private func primaryText(for participant: ParticipantSummary) -> String {
        if let name = participant.name, !name.isEmpty {
            return name
        }
        if let email = participant.email, !email.isEmpty {
            return email
        }
        if let phoneNumber = participant.phoneNumber, !phoneNumber.isEmpty {
            return phoneNumber
        }
        return "Participant"
    }
    
    private func secondaryText(for participant: ParticipantSummary) -> String? {
        let name = participant.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = participant.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = participant.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !name.isEmpty {
            if !email.isEmpty {
                return email
            }
            if !phone.isEmpty {
                return phone
            }
        } else if !email.isEmpty && !phone.isEmpty {
            return phone
        }
        return nil
    }
}

/// ShareSheet is needed in InviteView since there is a problem with ShareLink when presenting from a sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

#Preview {
    var event = ManagerEvent.mock()
    event.invitedEmails = ["first@example.com", "second@example.com"]
    event.participants = [
        ParticipantSummary(name: "Alex Doe", email: "alex@example.com", phoneNumber: nil),
        ParticipantSummary(name: nil, email: "pat@example.com", phoneNumber: "12345678")
    ]
    return InviteView(
        store: .init(
            initialState: .init(
                event: event,
                inviteLink: "https://example.com/invite",
                shareText: "Join my session at https://example.com/invite"
            ),
            reducer: {
                InviteFeature()
            }
        )
    )
}
