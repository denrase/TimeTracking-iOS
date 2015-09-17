//
//  AppDelegate.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 09.03.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import UIKit
import TimeTrackingKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        setupAppearence()
        
        return true
    }
    
    func setupAppearence() {
        self.window?.tintColor = TimeTrackingColors.lightBlue()
        UINavigationBar.appearance().barTintColor = TimeTrackingColors.blue()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().titleTextAttributes = titleDict as? [String : AnyObject]
    }
    
    func application(application: UIApplication,
        handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?,
        reply: (([NSObject : AnyObject]?) -> Void)) {
            // could be used to update ui of application if it is currently running while operation is performed on the watch
            
    }
}
