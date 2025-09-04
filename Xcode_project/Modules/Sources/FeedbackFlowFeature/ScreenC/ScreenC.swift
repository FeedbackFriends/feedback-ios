import ComposableArchitecture

@Reducer
public struct ScreenC: Sendable {
    public init() {}
    @ObservableState
    public struct State: Equatable, Sendable {}
    
    public enum Action {}
    
    enum CancelID { case timer }
    
    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
