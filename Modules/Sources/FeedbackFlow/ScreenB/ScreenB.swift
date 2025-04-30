import ComposableArchitecture

@Reducer
public struct ScreenB {
    
    public init () {}
    @ObservableState
    public struct State: Equatable {}
    
    public enum Action {}
    
    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
