//
//  AppDelegate.swift
//  aEvents
//
//  Created by Dang Duc Nam on 2/3/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleSignIn
import FBSDKLoginKit
import UserNotifications
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFirstTime") == nil {
            defaults.set("No", forKey:"isFirstTime")
            defaults.synchronize()
            let storyboard = UIStoryboard(name: "Main", bundle: nil) //Write your storyboard name
            let viewController = storyboard.instantiateViewController(withIdentifier: "TutorialPageController") as! TutorialPageController
            self.window?.rootViewController = viewController
            self.window?.makeKeyAndVisible()
        }
        
        //Up
        //UIApplication.shared.applicationIconBadgeNumber = 2
        
        
        BITHockeyManager.shared().configure(withIdentifier: "85e15d52d1c9414cb27ada962ce00a04")
        // Do some additional configuration if needed here
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
        //application.applicationIconBadgeNumber = 999999999999999999

        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        // [END register_for_notifications]

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        let googleServiceFile: String? = Bundle.main.infoDictionary!["GoogleServiceFile"] as! String?
        let fireBaseConfigFile = Bundle.main.path(forResource: googleServiceFile!, ofType: "plist")
        let firOptions = FIROptions(contentsOfFile: fireBaseConfigFile)
        FIRApp.configure(with: firOptions!)
        
        // [START add_token_refresh_observer]
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        // [END add_token_refresh_observer]
        
        GMSServices.provideAPIKey(getGoogleMapAPIKey())
//        URLCache.shared.remoßveAllCachedResponses()
        
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (accepted, error) in
//            if !accepted {
//                print("accept denied.")
//            }
//        }
//        application.registerForRemoteNotifications()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
//        FIRApp.configure()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let ggCheck = GIDSignIn.sharedInstance().handle(url as URL!,sourceApplication: sourceApplication,annotation: annotation)
        let fbCheck = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return ggCheck || fbCheck
    }
    
    func getGoogleMapAPIKey() -> String {
        if  let infoPlist = Bundle.main.infoDictionary,
            let config = infoPlist["Google_Map_API_Key"] as? String {
            return config
        } else {
            return ""
        }
    }
    
    func scheduleNotification(notification: Notification) {
        if #available(iOS 10.0, *) {
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
            let startTime = Date(timeIntervalSince1970: (Double(notification.startTime) ?? 0)/1000)
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "EEEE MMM dd, yyyy HH:mm"
            
            let content = UNMutableNotificationContent()
            if(notification.type == "1"){
                content.title = notification.title
                content.body = notification.message
            }
            else {
                content.title = notification.topicName
                if(notification.typeStatus == "1"){
                    content.body = " Location: \(notification.location) \r\n Time: \(dateFormatterPrint.string(from: startTime))"
                }
                else{
                    content.body = " Location: \(notification.location) \r\n Topic Canceled"
                }
            }
            content.sound = UNNotificationSound.default()
            if let path = Bundle.main.path(forResource: "logo", ofType: "png") {
                let url = URL(fileURLWithPath: path)
                
                do {
                    let attachment = try UNNotificationAttachment(identifier: "pig", url: url, options: nil)
                    content.attachments = [attachment]
                } catch {
                    print("Failed to load The attachment.")
                }
            }
            
            let request = UNNotificationRequest(identifier: "pushNotification", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("error : \(error)")
                }
            }
        }
    }
    
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        print(userInfo)
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "myNotif"), object: nil)

        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        print(userInfo)
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // Let FCM know about the message for analytics etc.
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
        // handle your message
        print(userInfo)
    }
    
    
    
    // [END receive_message]
    // [START refresh_token]
    @objc func tokenRefreshNotification(notification: NSNotification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        initConnectToFcm()
    }
    // [END refresh_token]
    
    func connectToFcm(events: [Int]) {
//        print(FIRInstanceID.instanceID().token()!)
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            print("errrr111111")
            return;
        }
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                for (_, eventId) in events.enumerated() {
                    print(eventId)
                    FIRMessaging.messaging().subscribe(toTopic: "/topics/i\(eventId)")
                }
                print("Connected to FCM with topics.")
            }
        }
    }
    
    func disconectToFcm(){
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        if(token != ""){
            Services.getEventIds(token: token as String){
                result in
                switch result {
                case .success(let events):
                    for (_, eventId) in events.enumerated() {
                        FIRMessaging.messaging().unsubscribe(fromTopic: "/topics/i\(eventId)")
                    }
                    FIRMessaging.messaging().disconnect()
                    print("Disconnected to FCM with topics.")
                case .failure:
                    print("error")
                }
            }
        }
    }
    
    func initConnectToFcm(){
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        if(token != ""){
            Services.getEventIds(token: token as String){
                [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let events):
                    strongSelf.connectToFcm(events: events)
                case .failure:
                    print("error")
                }
            }
        }
    }
    
    // [END connect_to_fcm]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let chars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
//        var token = ""
        
//        for i in 0..<deviceToken.count {
//            token += String(format: "%02.2hhx", arguments: [chars[i]])
//        }
        
//        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
//        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.prod)
    }
    
    // [START connect_on_active]
    func applicationDidBecomeActive(_ application: UIApplication) {
        initConnectToFcm()
    }
    // [END connect_on_active]
    // [START disconnect_from_fcm]
    func applicationDidEnterBackground(_ application: UIApplication) {
//        FIRMessaging.messaging().disconnect()
//        print("Disconnected from FCM.")
    }
    // [END disconnect_from_fcm]

}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    //Called when a notification is delivered to a foreground app.
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        print("User Info = ",notification.request.content)
        
//        let arrayMessage = [
//            "type_broadcast" : "1",
//            "title" : notification.request.content.title,
//            "message" : notification.request.content.body
//        ]
        
//        let notification = Notification(dictionary: arrayMessage as [String : AnyObject])
//        NotificationViewController.notifications.insert(notification, at: 0)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "myNotif"), object: nil)
//        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        
        completionHandler([.alert, .badge, .sound])
    }
    
    //Called to let your app know which action was selected by the user for a given notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info = ",response.notification.request.content.userInfo)
        completionHandler()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "myNotif"), object: nil)
    }

}

// [END ios_10_message_handling]
// [START ios_10_data_message_handling]
//@available(iOS 10, *)
extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        //print(remoteMessage.appData as! [String: Any])
        let arrayMessage = remoteMessage.appData as! [String: AnyObject]
        let notification = Notification(dictionary: arrayMessage)
//        NotificationViewController.notifications.insert(notification, at: 0)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "myNotif"), object: nil)
//        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        scheduleNotification(notification: notification)
    }
    
}
// [END ios_10_data_message_handling]

