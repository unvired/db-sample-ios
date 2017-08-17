//
//  AppDelegate.swift
//  DB-Sample-ios
//
//  Created by Suman HS on 10/08/17.
//  Copyright © 2017 Suman HS. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , LoginActivityListener {
    
    var window: UIWindow?
    func displayHomeSceen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainVC") as! ViewController
        let navigationController:UINavigationController = UINavigationController(rootViewController: initialViewController)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    // MARK: - LoginActivityListener Methods
    func loginSuccessful() {
        UnviredFrameworkUtils.registerForAPNS()
        displayHomeSceen()
    }
    
    func authenticationAndActivationSuccessful() {
        UnviredFrameworkUtils.registerForAPNS()
        displayHomeSceen()
    }
    
    func loginFailedWithError(_ error: Error) {
        
        print("ERROR: " + error.localizedDescription)
        
        let alertController: UIAlertController = UIAlertController (
            title: NSLocalizedString("Error", comment: ""),
            message: error.localizedDescription,
            preferredStyle: UIAlertControllerStyle.alert)
        let alertAction: UIAlertAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(alertAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func authenticationAndActivationFailedWithError(_ error: Error!) {
        let alertController: UIAlertController = UIAlertController (title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(alertAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        //    self.window?.tintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.white
        
        //  Set all the Required parameters in LoginParameters.
        let loginParameters:LoginParameters = LoginParameters.shared()
        loginParameters.applicationWindow = self.window
        loginParameters.url =  "http://192.168.98.160:8080/UMP"
        loginParameters.applicationTitle = NSLocalizedString("DB-Sample-ios", comment: "")
        loginParameters.applicationLogoForiPad = nil
        loginParameters.applicationLogoForiPhone = nil
        loginParameters.redirectURL = "http://www.unvired.com"
        loginParameters.loginActivityListener = self
        loginParameters.loginButtonColor = UIColor.white
        loginParameters.supportedLoginTypes = [ LoginType().rawValue, LoginType.ADS.rawValue, LoginType.SAP.rawValue]
        loginParameters.hideGetMessageStatusInformation = true
        loginParameters.hideMessageProcessingStatusInformation  = true
        loginParameters.allowServerLookup = true
        
        // Call the Unvired Login API
        AuthenticationService.login()
        
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        return true
    }
    
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

