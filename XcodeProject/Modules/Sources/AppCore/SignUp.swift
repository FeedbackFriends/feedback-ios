import Combine
import DesignSystem
import SwiftUI
import Foundation
import ComposableArchitecture
import Model

@Reducer
public struct SignUp {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        case selectUserType(SelectUserType)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: Destination.State?
        public init(
            destination: Destination.State? = nil
        ) {
            self.destination = destination
        }
    }
    
    public enum Action: BindableAction {
        case signUpWithAppleButtonTap
        case signUpWithGoogleButtonTap
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
    }
    
    public init() {}
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.logClient) var logClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
                
            case .presentError(let error):
                state.destination = .alert(.init(error: error))
                return .none
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .signUpWithAppleButtonTap:
                return .run { send in
                    do {
                        _ = try await authClient.appleLogin()
                    }
                    catch let error as AuthenticationError where error == .loginCancelled {
                        return
                    }
                    catch {
                        await send(.presentError(error))
                    }
                }
                
            case .signUpWithGoogleButtonTap:
                return .run { send in
                    do {
                        _ = try await authClient.googleLogin()
                    }
                    catch let error as AuthenticationError where error == .loginCancelled {
                        return
                    }
                    catch {
                        await send(.presentError(error))
                    }
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

