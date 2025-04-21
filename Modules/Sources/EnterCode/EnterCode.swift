import Combine
import DesignSystem
import ComposableArchitecture
import Foundation
import Helpers
import SwiftUI

@Reducer
public struct EnterCode {
    
    @ObservableState
    public struct State: Equatable {
        var inputCode: String
        public var startFeedbackPincodeInFlight: Bool
        var disableStartFeedbackButton: Bool {
            if !PinCodeValidator.isValidPinCode(inputCode) || startFeedbackPincodeInFlight {
                return true
            }
            return false
        }
        public init(inputCode: String = "", startFeedbackPincodeInFlight: Bool = false) {
            self.inputCode = inputCode
            self.startFeedbackPincodeInFlight = startFeedbackPincodeInFlight
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case startFeedbackButtonTap
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case startFeedback(pinCode: String)
        }
    }
    
    public init() {}
    
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
             
            case .binding:
                return .none
                
            case .startFeedbackButtonTap:
                let input = state.inputCode
                state.inputCode = ""
                state.startFeedbackPincodeInFlight = true
                return .send(.delegate(.startFeedback(pinCode: input)))
                
            case .delegate:
                return .none
            }
        }
    }
}


