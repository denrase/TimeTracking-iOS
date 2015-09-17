//
//  TodayController.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 01.05.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import WatchKit
import Foundation

class TodayController: WKInterfaceController {
    
    @IBOutlet weak var disabledTimerLabel: WKInterfaceLabel!
    @IBOutlet weak var workedInterfaceTimer: WKInterfaceTimer!
    
    @IBOutlet weak var pausedTimeLabel: WKInterfaceLabel!
    
    @IBOutlet weak var startStopButton: WKInterfaceButton!
    
    var todaysWorkDay: WorkDay?
    
    override func willActivate() {
        super.willActivate()
        updateInterface()
        fetchStatus()
    }
    
    @IBAction func pressedStartStop() {
        if let today = todaysWorkDay {
            if (today.timeStatus() == WorkDay.Status.Running) {
                sendStop()
            }
            else {
                sendStart()
            }
        }
    }
    
    @IBAction func refresh() {
        fetchStatus()
    }
    
    func updateInterface() {
        if let today = self.todaysWorkDay {
            self.workedInterfaceTimer.setHidden(false)
            self.disabledTimerLabel.setHidden(true)
            
            self.startStopButton.setEnabled(true)
            
            if (today.timeStatus() == WorkDay.Status.Running) {
                self.startStopButton.setBackgroundColor(TimeTrackingColors.red())
                self.startStopButton.setTitle("STOP")
                self.workedInterfaceTimer.start()
            }
            else {
                self.startStopButton.setBackgroundColor(TimeTrackingColors.green())
                self.startStopButton.setTitle("START")
                self.workedInterfaceTimer.stop()
            }
            
            self.workedInterfaceTimer.setDate(today.todaysStartDate())
            
            let pausedHours = String(format: "%02d", today.pausedHoursAndMinutesToday().0)
            let pausedMinutes = String(format: "%02d", today.pausedHoursAndMinutesToday().1)
            self.pausedTimeLabel.setText("\(pausedHours):\(pausedMinutes)")
        }
        else {
            self.workedInterfaceTimer.setHidden(true)
            self.disabledTimerLabel.setHidden(false)
            
            self.startStopButton.setBackgroundColor(UIColor.lightGrayColor())
            self.startStopButton.setTitle("START")
            self.startStopButton.setEnabled(false)
            
            self.workedInterfaceTimer.setDate(NSDate())
            self.workedInterfaceTimer.stop()
            self.pausedTimeLabel.setText("--")
        }
    }
    
    func fetchStatus() {
        APIClient.sharedInstance.status { (workDay, error) -> Void in
            if (error == nil && workDay != nil) {
                self.todaysWorkDay = workDay;
            } else {
                print("Error retrieving status");
            }
            
            self.updateInterface()
        }
    }
    
    func sendStart() {
        startStopButton.setEnabled(false)
        APIClient.sharedInstance.start { (workDay, error) -> Void in
            if (error == nil && workDay != nil) {
                self.todaysWorkDay = workDay;
            } else {
                print("Error starting timetracking");
            }
            
            self.updateInterface()
        }
    }
    
    func sendStop() {
        startStopButton.setEnabled(false)
        APIClient.sharedInstance.stop { (workDay, error) -> Void in
            if (error == nil && workDay != nil) {
                self.todaysWorkDay = workDay;
            } else {
                print("Error stopping timetracking");
            }
            
            self.updateInterface()
        }
    }
}
