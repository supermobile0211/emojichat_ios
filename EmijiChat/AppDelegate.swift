//
//  AppDelegate.swift
//  EmijiChat
//
//  Created by Bender on 25.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseAuth
import GoogleSignIn
import Contacts
import UserNotifications

import Fabric
import Crashlytics

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

class MyUIAlertController: UIAlertController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //set this to whatever color you like...
        self.view.tintColor = UIColor(red: 98/255, green: 214/255, blue: 83/255, alpha: 1)
    }
}

extension AppDelegate: SINCallClientDelegate {
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("😊😊 incoming call")
    }
    
    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        print("😊😊 localNotificationForIncomingCall")
        let localNotif = SINLocalNotification()
        localNotif.alertBody = "test alert body"
        localNotif.alertAction = "test alert action"
        return localNotif
    }
}

extension AppDelegate: SINClientDelegate {
    func clientDidStart(_ client: SINClient!) {
        print("😊😊 clientDidStart")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("😊😊 clientDidFail")
    }
}

extension AppDelegate: SINManagedPushDelegate {
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        print("😊😊 didReceiveIncomingPushWithPayload\(payload)")
    }
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var contactStore = CNContactStore()
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        // Remove navbar bottom border
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        // Change status bar color
        UIApplication.shared.statusBarView?.backgroundColor = Constants.UI.barColor
        
        // Change UITextField UITextView cursor color
        UITextField.appearance().tintColor = Constants.UI.barColor
        UITextView.appearance().tintColor = Constants.UI.barColor
        
        // It need to disable user interaction while progress HUD is showing
        SVProgressHUD.setDefaultMaskType(.black)
        
        // Hide searchbar bottom border
        UISearchBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        configureFirebase(application)
        
        configureSinch()
        
        configureGoogleSignIn()
        
        checkIsUserLogged()
        
        return true
    }
    
    private func checkIsUserLogged() {
        if UserDefaults.standard.string(forKey: "username") != nil {
            let storyboard = UIStoryboard(name: "MainTabBar", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"MainTabBar") as! UITabBarController
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController?.present(viewController, animated: false, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "TermsPrivacyViewController", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"TermsPrivacyViewController") as! TermsPrivacyViewController
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController?.present(viewController, animated: false, completion: nil)
        }
    }
    
    private func configureGoogleSignIn() {
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }
    
    private func configureSinch() {
        /*
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        print("🤡🤡🤡 My UUID: \(uuid)")
        
        // Instantiate a Sinch client object
        sinchClient = Sinch.client(withApplicationKey: "a56e5f5a-4707-4f7c-900a-e0d57da2cf5a",
                                                  applicationSecret: "1dh9TXTPjk2cxRf3kxbFGA==",
                                                  environmentHost: "sandbox.sinch.com",
                                                  userId: "testUserIDBot")
        
        sinchClient.delegate = self;
        //commented to test push but is working
        //sinchClient.setSupportActiveConnectionInBackground(true)
        sinchClient.enableManagedPushNotifications()
        sinchClient.setSupportCalling(true)
        sinchClient.start()
        sinchClient.startListeningOnActiveConnection()
         */
    }
    
    private func configureFirebase(_ application: UIApplication) {
        // Use Firebase library to configure APIs
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        // Initialize the Google Mobile Ads SDK
        
        
        registerForRemoteNotifications(application)
    }
    
    private func registerForRemoteNotifications(_ application: UIApplication) {
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
        
        // Retrieve the current registration token
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "NO FCM token!")")
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to auth
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
//        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("DeviceToken: " + token)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
    }
    
    func requestForAccess(completionHandler: @escaping (_ accessGranded: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: .contacts, completionHandler: { (access, accessError) in
                if access {
                    completionHandler(access)
                } else {
                    if authorizationStatus == .denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(title: "Warnning", message: message)
                        })
                    }
                }
            })
        default:
            completionHandler(false)
        }
    }
    
    func showMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle:.alert)
        
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertController.addAction(dismissAction)
        
        let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
        let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
        
        presentedViewController.present(alertController, animated: true, completion: nil)
    }
    
}

// [START GoogleSignIn]
extension AppDelegate: GIDSignInDelegate {
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    // The sign-in flow has finished and was successful if |error| is |nil|.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("func sign(_ signIn: GIDSignIn!, didSignInFor Error: " + error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Auth.auth().signIn(with: credential) Error: " + error.localizedDescription)
                return
            }
        }
    }
}
// [END GoogleSignIn]


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        /*if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }*/
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        /*if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }*/
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

