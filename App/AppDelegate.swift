import ComposableArchitecture
import Helpers
import AppCore
import Combine
import FirebaseAuth
import FirebaseCore
import FirebasePerformance
import FirebaseMessaging
import FirebaseCrashlytics
import GoogleSignIn
import Tabbar
import DesignSystem
import SwiftUI
import UIKit
import UserNotifications
import Firebase
import UserNotifications
import EnterCode
import Logger

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let intialStore = Store(
        initialState: AppCore.State()
    ) {
        AppCore()
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        startApp()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        intialStore.send(.appDelegate(.didFinishLaunchingWithOptions(deviceId: deviceId)))
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM token received: \(fcmToken ?? "Not found")")
        intialStore.send(.appDelegate(.didReceiveRegistrationToken(fcmToken)))
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().setAPNSToken(deviceToken as Data, type: .prod)
        print("APNS Token Set: \(deviceToken)")
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        
        // Modify the existing notification content
        //        let modifiedContent = notification.request.content.mutableCopy() as! UNMutableNotificationContent
//        modifiedContent.title = "New Test Title"
//        modifiedContent.body = "This is a test message replacing all notifications."
//        
//        // ✅ Use the existing notification identifier to update it
//        let modifiedRequest = UNNotificationRequest(identifier: notification.request.identifier,
//                                                    content: modifiedContent,
//                                                    trigger: notification.request.trigger)
//        
//        // Replace the original notification with the modified one
//        UNUserNotificationCenter.current().add(modifiedRequest)
        
        // ✅ Allow the modified notification to be displayed
        completionHandler([.banner, .sound, .list])
    }
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

//func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    
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
//}
//}
//
//enum NotificationTypeString: String {
//    case startFeedback = "START_FEEDBACK"
//    case viewMeeting = "VIEW_MEETING"
//    case teamInvite = "TEAM_INVITE"
//}
