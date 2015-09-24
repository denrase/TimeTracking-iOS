//
//  AppDelegate.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 09.03.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        setupAppearence()
        setupRootViewController()
        sendDataToWatch()
        
        return true
    }
    
    func setupRootViewController() {
        
        if Store.isLoggedIn() {
            let navigationController = TodayViewController.todayNavigationController()
            let todayController = navigationController.topViewController as! TodayViewController
            todayController.loggedOut = {
                Store.clearAuthenticationToken()
                APIClient.sharedInstance.clearAuthenticationToken()
                
                self.sendDataToWatch()
                self.setupRootViewController()
            }
            window?.rootViewController = navigationController
        }
        else {
            let navigationController = LoginViewController.loginNavigationController()
            let loginController = navigationController.topViewController as! LoginViewController
            loginController.loggedIn = {
                APIClient.sharedInstance.setApiBaseUrl(Store.apiBaseUrl())
                APIClient.sharedInstance.setAuthenticationToken(Store.authenticationToken())
                
                self.sendDataToWatch()
                self.setupRootViewController()
            }
            window?.rootViewController = navigationController
        }
        
        window?.makeKeyAndVisible()
    }
    
    func setupAppearence() {
        self.window?.tintColor = TimeTrackingColors.lightBlue()
        UINavigationBar.appearance().barTintColor = TimeTrackingColors.blue()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        let buttonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)];
        let titleAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightMedium)];
        
        UIBarButtonItem.appearance().setTitleTextAttributes(buttonAttributes as? [String : AnyObject], forState: UIControlState.Normal)
        UINavigationBar.appearance().titleTextAttributes = titleAttributes as? [String : AnyObject]
    }
    
    // MARK: WatchConnectivity
    
    func sendDataToWatch() {
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            do {
                let data = ["token": Store.authenticationToken(), "endpoint": Store.apiBaseUrl()]
                try WCSession.defaultSession().updateApplicationContext(data)
            } catch {
                print("Error sending application context.")
            }
        }
    }
}
