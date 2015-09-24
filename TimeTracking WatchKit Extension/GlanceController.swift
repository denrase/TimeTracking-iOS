//
//  GlanceController.swift
//  TimeTracking
//
//  Created by Daniel Griesser on 26/05/15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//


import WatchKit
import Foundation

class GlanceController: WKInterfaceController {

    var todaysWorkDay: WorkDay?
    
    @IBOutlet weak var workedEmptyLabel: WKInterfaceLabel!
    @IBOutlet weak var workedInterfaceTimer: WKInterfaceTimer!
    @IBOutlet weak var pausedLabel: WKInterfaceLabel!
    
    override func willActivate() {
        super.willActivate()
        setupApiClient()
        updateInterface()
        fetchStatus()
    }
    
    func setupApiClient() {
        APIClient.sharedInstance.setApiBaseUrl(Store.apiBaseUrl())
        APIClient.sharedInstance.setAuthenticationToken(Store.authenticationToken())
    }
    
    func updateInterface() {
        if let today = todaysWorkDay {
            workedEmptyLabel.setHidden(true)
            workedInterfaceTimer.setHidden(false)
            
            self.workedInterfaceTimer.setDate(today.todaysStartDate())
            
            let pausedHours = String(format: "%02d", today.pausedHoursAndMinutesToday().0)
            let pausedMinutes = String(format: "%02d", today.pausedHoursAndMinutesToday().1)
            self.pausedLabel.setText("\(pausedHours):\(pausedMinutes)")
        }
        else {
            workedEmptyLabel.setHidden(false)
            workedInterfaceTimer.setHidden(true)
            pausedLabel.setText("--")
        }
    }
    
    func fetchStatus() {
        APIClient.sharedInstance.status { (workDay, error) -> Void in
            if (error == nil && workDay != nil) {
                self.todaysWorkDay = workDay
            } else {
                print("Error retrieving status");
            }
            self.updateInterface()
        }
    }
}
