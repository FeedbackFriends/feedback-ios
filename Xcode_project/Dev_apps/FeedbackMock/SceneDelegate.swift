//import AppCore
//import SwiftUI
//
//class SceneDelegate: NSObject, UIWindowSceneDelegate {
//    
//    var window: UIWindow?
//
//    func scene(
//        _ scene: UIScene,
//        willConnectTo session: UISceneSession,
//        options connectionOptions: UIScene.ConnectionOptions
//    ) {
//        let deeplink: Deeplink? = if
//            let response = connectionOptions.notificationResponse {
//            DeeplinkParser.fromNotificationPayload(response.notification.request.content.userInfo)
//        } else {
//            nil
//        }
//        guard let deeplink else { return }
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            appDelegate.intialStore.send(.onAppOpen(deeplink))
//        }
//    }
//    
//    func sceneDidDisconnect(_ scene: UIScene) {
//      
//    }
//
//    func sceneDidBecomeActive(_ scene: UIScene) {
//      
//    }
//
//    func sceneWillResignActive(_ scene: UIScene) {
//      
//    }
//
//    func sceneWillEnterForeground(_ scene: UIScene) {
//      
//    }
//
//    func sceneDidEnterBackground(_ scene: UIScene) {
//      
//    }
//}
