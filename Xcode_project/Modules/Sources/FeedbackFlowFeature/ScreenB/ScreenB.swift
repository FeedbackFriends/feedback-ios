import ComposableArchitecture

@Reducer
public struct ScreenB: Sendable {
    
    public init () {}
    @ObservableState
    public struct State: Equatable, Sendable {}
    
    public enum Action {}
    
    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
