//
//  AppDelegate.swift
//  TheMove
//
//  Created by User 2 on 2/22/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore
import UserNotifications
import FirebaseMessaging
import FirebaseInstanceID
import BRYXBanner
import GoogleSignIn
import FBSDKCoreKit
import GoogleMaps


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var reachability: Reachability?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
         FirebaseApp.configure()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        GMSServices.provideAPIKey("AIzaSyD4cUO3jb15sPLFvpiD8hB24GEnNLJzwtU")
      //  GMSPlacesClient.provideAPIKey("AIzaSyD4cUO3jb15sPLFvpiD8hB24GEnNLJzwtU")

        
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.black
        UITabBar.appearance().barTintColor = UIColor.black
        let color2 = UIColor(rgb: 0xFF8C00)
        UITabBar.appearance().tintColor = color2
        
       GIDSignIn.sharedInstance().clientID = "123746515481-vei54uk68qfgctqm0c3qko7nfjfs81ae.apps.googleusercontent.com"
        
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: { (isgranded, err) in
            if err != nil{
                
            }else{
                
                UNUserNotificationCenter.current().delegate = self
                
                Messaging.messaging().delegate = self
                Messaging.messaging().isAutoInitEnabled = true
              
                UNUserNotificationCenter.current().delegate = self
                
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }

            }
            
        })
        
        if let appAuth = UserDefaults.standard.dictionary(forKey: "loginDetails"){

        print(appAuth)
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "HomeTabbarViewController") as! HomeTabbarViewController
            let navigationController = UINavigationController(rootViewController: initialViewControlleripad)
             navigationController.navigationBar.prefersLargeTitles = true

            navigationController.navigationBar.isTranslucent = false
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()

      }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotificaiton),
                                               name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url as URL,
                                                                   sourceApplication: sourceApplication,
                                                                   annotation: annotation)
        
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
        return googleDidHandle || facebookDidHandle
    }
    
    private func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,  annotation: [:])

    }
    
    class func sharedAppDelegate() -> AppDelegate?
    {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    @objc func tokenRefreshNotificaiton(notification: NSNotification) {
        let refreshedToken = InstanceID.instanceID().token()!
        print("InstanceID token: \(refreshedToken)")
        UserDefaults.standard.removeObject(forKey: "fcm_id")
        UserDefaults.standard.set(refreshedToken, forKey:"fcm_id")
        
        connectToFCM()
        
    }
    
    func connectToFCM(){
        
        if let token = InstanceID.instanceID().token() {
            print("FIREBASE: Token \(token) fetched")

            UserDefaults.standard.removeObject(forKey: "fcm_id")
            UserDefaults.standard.set(token, forKey:"fcm_id")

        } else {
            print("FIREBASE: Unable to fetch token");
        }
        
        
        Messaging.messaging().shouldEstablishDirectChannel = true
    
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
         Messaging.messaging().shouldEstablishDirectChannel = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        connectToFCM()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {

        print("Registered with FCM with token:", fcmToken)
        connectToFCM()
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        print(remoteMessage)
        
    }
    static func showAlertView(vc : UIViewController, titleString : String , messageString: String) ->()
    {
        let alertView = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "ok", style: .cancel) { (alert) in
            vc.dismiss(animated: true, completion: nil)
        }
        alertView.addAction(alertAction)
        vc.present(alertView, animated: true, completion: nil)
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    
        print(userInfo)
        
        let alertMessages: NSDictionary = userInfo as NSDictionary
        
        let alertTitle : NSDictionary = alertMessages.value(forKey: "aps") as! NSDictionary
      
        let alertshowIng: NSDictionary = alertTitle.value(forKey: "alert") as! NSDictionary
        
        let userName: String = alertMessages.value(forKey: "gcm.notification.username") as! String
       
        let banner = Banner(title: alertshowIng.value(forKey: "title") as? String , subtitle: (alertshowIng.value(forKey: "body") as! String), image: LetterImageGenerator.imageWith(name: userName), backgroundColor: UIColor.black)
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)
        

    }
    
    

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "TheMove")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

//
