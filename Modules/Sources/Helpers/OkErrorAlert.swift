import ComposableArchitecture

public func okErrorAlert<T>(message: String) -> AlertState<T> {
    AlertState<T>.init(
        title: { TextState("Error") },
        actions: {
            .init(role: .cancel, label: { TextState("Ok") })
        },
        message: { TextState(message) }
    )
}
