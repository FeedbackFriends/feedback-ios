import ComposableArchitecture
import DependencyClients
import Helpers
import APIClient
import Logger

@Reducer
public struct AppDelegateReducer {
    @ObservableState
    public struct State {
        var didLoad: Bool = false
        public init() {}
    }
    public enum Action {
        case didFinishLaunchingWithOptions
        case didReceiveRegistrationToken(String?)
        case didReceiveNotification(NotificationType)
        public enum NotificationType {
            case startFeedback(code: Int, email: String)
            case viewMeeting(meetingID: Int, email: String)
            case teamInvite(email: String)
        }
    }
    
    public init() {}
    @Dependency(\.firebaseClient) var firebaseClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.logClient) var logger
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .didFinishLaunchingWithOptions:
                return .none
                
            case .didReceiveRegistrationToken(let fcmToken):
                return .run { send in
                    try await apiClient.updateFcmToken(fcmToken)
                }
                
            case .didReceiveNotification(_):
                fatalError("Notifications not implemented")
//                switch notification {
//                    
//                case .startFeedback(code: let code, email: let email):
//                    fatalError("Todo")
//                case .viewMeeting(meetingID: let meetingID, email: let email):
//                    fatalError("Todo")
//                case .teamInvite(email: let email):
//                    fatalError("Todo")
//                }
//                return .none
            }
        }
    }
}





////
////  File.swift
////
////
////  Created by Nicolai Dam on 28/09/2023.
////
//
//import Foundation
//import LoggedInFeature
//
//public extension AppViewModel {
//    enum AppDelegate {
//        case didFinishLaunchingWithOptions
//        case didReceiveRegistrationToken(String?)
//        case didReceiveNotification(NotificationType)
//    }
//    enum NotificationType {
//        case startFeedback(code: Int, email: String)
//        case viewMeeting(meetingID: Int, email: String)
//        case teamInvite(email: String)
//    }
//}
//
//extension AppViewModel {
//
//    public func appdelegate(_ input : AppDelegate) {
//
//        switch input {
//        case .didFinishLaunchingWithOptions:

//            return
//
//        case .didReceiveRegistrationToken(let fcmToken):
//
//            return
//
//        case .didReceiveNotification(let notification):
//            self.notificationDeeplink = self.$initialStateLoaded.removeDuplicates().sink { @MainActor [unowned self] appLoaded in
//
//                guard let userType = appLoaded,
//                      let loggedInEmail = firebaseClient.userInfo().0,
//                      case .loggedIn = userType
//                else {
//                    self.notificationDeeplink?.cancel()
//                    return
//                }
//
//                guard let meetingManagerModeEnabled = persistenceClient.meetingManagerEnabled.load() else { fatalError() }
//
//                switch notification {
//                case .startFeedback(let code, email: let email):
//                    guard email == loggedInEmail else { return }
//                    self.deeplinkStartFeedback(code: code, meetingManagerModeEnabled: meetingManagerModeEnabled)
//                case .viewMeeting(let meetingID, let email):
//                    guard email == loggedInEmail else { return }
//                    self.deeplinkViewMeeting(meetingID: meetingID, meetingManagerModeEnabled: meetingManagerModeEnabled)
//                case .teamInvite(email: let email):
//                    guard email == loggedInEmail else { return }
//                    self.deeplinkTeamInvitations(meetingManagerModeEnabled: meetingManagerModeEnabled)
//                }
//
//                self.notificationDeeplink?.cancel()
//            }
//        }
//    }
//
//
//    func deeplinkStartFeedback(code: Int, meetingManagerModeEnabled: Bool) {
//        fatalError("Fix me")
////        let meetingHolderViewModel = TabbarViewModel(meetingManagerModeEnabled: meetingManagerModeEnabled, selectedTab: .feedback, enterCode: .init())
//////        meetingHolderViewModel.enterCode.feedbackButtonViewModel.inputCode = code
////        meetingHolderViewModel.enterCode.feedbackButtonViewModel.continueButtonTapped(inputCode: code)
////        self.setDestination(.meetingHolder(meetingHolderViewModel))
//    }
//
//    func deeplinkViewMeeting(meetingID: Int, meetingManagerModeEnabled: Bool) {
//        #warning("Fix")
//        fatalError("Fix me")
////        let meetingHolderViewModel = TabbarViewModel(meetingManagerModeEnabled: meetingManagerModeEnabled, selectedTab: .events)
////        meetingHolderViewModel.eventOverview.fetchEvents()
////        meetingHolderViewModel.eventOverview.navigateToEventDetailWhenListIsFetched(meetingID: .init(meetingID))
////        self.setDestination(.meetingHolder(meetingHolderViewModel))
//    }
//
//    func deeplinkTeamInvitations(meetingManagerModeEnabled: Bool) {
//        #warning("fix")
//        fatalError("Fix me")
////        let meetingHolderViewModel = TabbarViewModel(meetingManagerModeEnabled: meetingManagerModeEnabled, selectedTab: .teams)
////        meetingHolderViewModel.teamsOverview.fetchTeams()
////        meetingHolderViewModel.teamsOverview.navigateToInvitationWhenListIsFetched()
////        self.setDestination(.meetingHolder(meetingHolderViewModel))
//    }
//}
