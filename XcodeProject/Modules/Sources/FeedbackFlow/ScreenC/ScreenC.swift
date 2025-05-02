import ComposableArchitecture

@Reducer
public struct ScreenC {
    public init() {}
    @ObservableState
    public struct State: Equatable {}
    
    public enum Action {}
    
    enum CancelID { case timer }
    
    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
