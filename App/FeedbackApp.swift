import ComposableArchitecture
import DependencyClients
import AppCore
import Combine
import FirebaseAuth
import FirebaseCore
import FirebasePerformance
import FirebaseMessaging
import FirebaseCrashlytics
import GoogleSignIn
import LoggedInFeature
import DesignSystem
import SwiftUI
import UIKit
import UserNotifications
import Firebase
import UserNotifications
import EnterCode
import Logger


@main
struct FeedbackApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppCoreView(store: appDelegate.intialStore)
                
        }
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            let url = urlContext.url
            _ = Auth.auth().canHandle(url)
        }
    }
}


final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let intialStore = Store(
        initialState: AppCore.State()
    ) {
        AppCore()
    }
    
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = AppDelegate.self
        return sceneConfig
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        startApp()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        intialStore.send(.appDelegate(.didFinishLaunchingWithOptions))
        return true
    }
}

extension AppDelegate: @preconcurrency MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        intialStore.send(.appDelegate(.didReceiveRegistrationToken(fcmToken)))
    }
}

extension AppDelegate : @preconcurrency UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
        ) -> Void ) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.banner]])
    }
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter,
    //                                didReceive response: UNNotificationResponse,
    //                                withCompletionHandler completionHandler: @escaping () -> Void) {
    //        let userInfo = response.notification.request.content.userInfo
    //
    //        appViewModel.handleNotification()
    //
    ////        if let messageID = userInfo[gcmMessageIDKey] {
    ////            print("Message ID from userNotificationCenter didReceive: \(messageID)")
    ////        }
    //
    //        completionHandler()
    //    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        
        //        let content = response.notification.request.content
        //
        //        guard
        //            let typeAsString = content.userInfo["type"] as? String,
        //            let email = content.userInfo["email"] as? String,
        //            let type = NotificationTypeString(rawValue: typeAsString) else { return }
        
        //        switch type {
        //        case .startFeedback:
        //            guard let code = content.userInfo["code"] as? String, let codeAsInt = Int(code) else { return }
        ////            self.appViewModel.appdelegate(.didReceiveNotification(.startFeedback(code: codeAsInt, email: email)))
        //            return
        //
        //        case .viewMeeting:
        //            guard let meetingID = content.userInfo["meetingID"] as? String,
        //                  let meetingIDAsInt = Int(meetingID) else { return }
        //            self.appViewModel.appdelegate(.didReceiveNotification(.viewMeeting(meetingID: meetingIDAsInt, email: email)))
        //            return
        //
        //        case .teamInvite:
        //            self.appViewModel.appdelegate(.didReceiveNotification(.teamInvite(email: email)))
        //            return
        //        }
    }
}

enum NotificationTypeString: String {
    case startFeedback = "START_FEEDBACK"
    case viewMeeting = "VIEW_MEETING"
    case teamInvite = "TEAM_INVITE"
}
