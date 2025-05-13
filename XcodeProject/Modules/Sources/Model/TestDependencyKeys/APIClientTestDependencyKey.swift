import ComposableArchitecture

public extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

extension APIClient: TestDependencyKey {
    public static let previewValue = APIClient()
    public static let testValue = APIClient(
        deleteAccount: {},
        updateAccount: { _, _, _ in},
        linkFCMTokenToAccount: { _ in },
        logout: {},
        getSession: { .mock() },
        startFeedbackSession: { _ in .mock },
        submitFeedback: { _, _ in true },
        createEvent: { _ in .mock() },
        updateEvent: { _, _ in .mock() },
        deleteEvent: { _ in },
        createAccount: { _ in .mock() },
        sessionChangedListener: { .never },
        joinEvent: { _ in },
        markEventAsSeen: { _ in },
        updateAccountRole: { _ in },
        getMockToken: { "" },
        getUpdatedSession: { .mock },
        markActivityAsSeen: { }
    )
}
