//
//  BackgroundTask.swift
//  TimeTracking
//
//  Created by Daniel Griesser on 27/05/15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import Foundation
import UIKit

class BackgroundTask {
    private let application: UIApplication
    private var identifier = UIBackgroundTaskInvalid
    
    init(application: UIApplication) {
        self.application = application
    }
    
    class func run(application: UIApplication, handler: (BackgroundTask) -> ()) {
        // NOTE: The handler must call end() when it is done
        
        let backgroundTask = BackgroundTask(application: application)
        backgroundTask.begin()
        handler(backgroundTask)
    }
    
    func begin() {
        self.identifier = application.beginBackgroundTaskWithExpirationHandler {
            self.end()
        }
    }
    
    func end() {
        if (identifier != UIBackgroundTaskInvalid) {
            application.endBackgroundTask(identifier)
        }
        
        identifier = UIBackgroundTaskInvalid
    }
}