import Combine
import DesignSystem
import SwiftUI
import Foundation
import DependencyClients
import ComposableArchitecture
import Helpers
import ComposableArchitecture
import SwiftUI
import APIClient

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
        var navigateToEnterEmail: Bool = false
        var navigateToEmailSent: Bool = false
        var selectedUserType: Claim?
        var disableContinueButton: Bool {
            selectedUserType == nil
        }
        var navigationTitle = "Sign up"

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
    
    @Dependency(\.firebaseClient) var firebaseClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.logClient) var logClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
                
            case .presentError(let error):
                state.destination = .alert(okErrorAlert(message: error.localizedDescription))
                return .none
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .signUpWithAppleButtonTap:
                return .run { send in
                    do {
                        _ = try await firebaseClient.appleLogin()
                    }
                    catch let error {
                        await send(.presentError(error))
                    }
                }
                
            case .signUpWithGoogleButtonTap:
                return .run { send in
                    do {
                        _ = try await firebaseClient.googleLogin()
                    }
                    catch let error {
                        await send(.presentError(error))
                    }
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

