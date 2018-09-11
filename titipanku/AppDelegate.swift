//
//  AppDelegate.swift
//  titipanku
//
//  Created by Ricky Wirawan on 27/03/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import MidtransKit
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate, MessagingDelegate{
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var cekLogged : Bool = UserDefaults.standard.bool(forKey: "logged")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        MidtransConfig.shared().setClientKey("SB-Mid-client-P68uFVZDfaVLBPfq", environment: .sandbox,
                                             merchantServerURL: "http://titipanku.xyz/api/charge.php")
        MidtransCreditCardConfig.shared().paymentType = .twoclick
        
        FirebaseApp.configure()
        //facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        UIApplication.shared.statusBarStyle = .lightContent

        UINavigationBar.appearance().barTintColor = UIColor(hex: "#3867d6")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        UINavigationBar.appearance().tintColor = .white
        let layout = UICollectionViewFlowLayout()
        let homeControllers = homeController(collectionViewLayout: layout)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        //window?.rootViewController = UINavigationController(rootViewController: homeControllers)
        window?.rootViewController = TabController()
        
//        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
//
//            // If your app wasn’t running and the user launches it by tapping the push notification, the push notification is passed to your app in the launchOptions
//
//            let aps = notification["aps"] as! [String: AnyObject]
//            UIApplication.shared.applicationIconBadgeNumber = 0
//        }
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        
        return true
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        print("Firebase registration token: \(fcmToken)")
        
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String , let token : String = fcmToken{
            
            let parameter: Parameters = ["email": emailNow,"token":token]
            print (parameter)
            Alamofire.request("http://titipanku.xyz/api/UpdateDeviceUser.php",method: .get, parameters: parameter).responseJSON {
                response in
                
                //mengambil json
                let json = JSON(response.result.value)
                print(json)
               
            }
        }
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func appl2ication(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            //google
            GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,annotation: [:])
            
            //facebook
            let handle = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: [UIApplicationOpenURLOptionsKey.annotation])
            
            return handle
    }
    
    
    
    //akhir google sigin in
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

//// Push Notificaion
//extension AppDelegate {
//    func registerForPushNotifications() {
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
//                [weak self] (granted, error) in
//                print("Permission granted: \(granted)")
//
//                guard granted else {
//                    print("Please enable \"Notifications\" from App Settings.")
//                    self?.showPermissionAlert()
//                    return
//                }
//
//                self?.getNotificationSettings()
//            }
//        } else {
//            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
//            UIApplication.shared.registerUserNotificationSettings(settings)
//            UIApplication.shared.registerForRemoteNotifications()
//        }
//    }
//
//    @available(iOS 10.0, *)
//    func getNotificationSettings() {
//
//        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
//            print("Notification settings: \(settings)")
//            guard settings.authorizationStatus == .authorized else { return }
//            DispatchQueue.main.async {
//                UIApplication.shared.registerForRemoteNotifications()
//            }
//        }
//    }
//
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//        let tokenParts = deviceToken.map { data -> String in
//            return String(format: "%02.2hhx", data)
//        }
//
//        let token = tokenParts.joined()
//        print("Device Token: \(token)")
//        //UserDefaults.standard.set(token, forKey: DEVICE_TOKEN)
//    }
//
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Failed to register: \(error)")
//    }
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//
//        // If your app was running and in the foreground
//        // Or
//        // If your app was running or suspended in the background and the user brings it to the foreground by tapping the push notification
//
//        print("didReceiveRemoteNotification /(userInfo)")
//
//        guard let dict = userInfo["aps"]  as? [String: Any], let msg = dict ["alert"] as? String else {
//            print("Notification Parsing Error")
//            return
//        }
//    }
//
//    func showPermissionAlert() {
//        let alert = UIAlertController(title: "WARNING", message: "Please enable access to Notifications in the Settings app.", preferredStyle: .alert)
//
//        let settingsAction = UIAlertAction(title: "Settings", style: .default) {[weak self] (alertAction) in
//            self?.gotoAppSettings()
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//
//        alert.addAction(settingsAction)
//        alert.addAction(cancelAction)
//
//        DispatchQueue.main.async {
//            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    private func gotoAppSettings() {
//
//        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
//            return
//        }
//
//        if UIApplication.shared.canOpenURL(settingsUrl) {
//            UIApplication.shared.openURL(settingsUrl)
//        }
//    }
//}

