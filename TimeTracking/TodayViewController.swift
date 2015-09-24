//
//  StartStopViewController.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 09.03.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {
    
    @IBOutlet weak var timeTodayLabel: UILabel!
    @IBOutlet weak var pauseTodayLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    
    var loggedOut : (() -> Void)?
    
    var todaysWorkDay: WorkDay?
    var updateTimer: NSTimer?
    var tick = false;
    
    class func todayNavigationController() -> UINavigationController {
        let storyboard = UIStoryboard(name: "Today", bundle: nil)
        return storyboard.instantiateInitialViewController() as! UINavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateInterface()
        fetchStatus()
    }
    
    // Setup
    
    func updateInterface() {
        setupStartStopButton()
        setupLabels()
        startStopUpdateTimer()
    }
    
    func setupLabels() {
        if let workDay = self.todaysWorkDay {
            tick = !tick
            
            if workDay.timeStatus() == WorkDay.Status.Stopped {
                tick = true;
                updateTimer?.invalidate()
            }
            
            let workedHours = String(format: "%02d", workDay.workedHoursAndMinutesToday().0)
            let workedMinutes = String(format: "%02d", workDay.workedHoursAndMinutesToday().1)
            let pausedHours = String(format: "%02d", workDay.pausedHoursAndMinutesToday().0)
            let pausedMinutes = String(format: "%02d", workDay.pausedHoursAndMinutesToday().1)
            
            if tick {
                self.timeTodayLabel.text = "\(workedHours):\(workedMinutes)"
            }
            else {
                self.timeTodayLabel.text = "\(workedHours) \(workedMinutes)"
            }
            
            self.pauseTodayLabel.text = "\(pausedHours):\(pausedMinutes)"
        }
        else {
            self.timeTodayLabel.text = "--"
            self.pauseTodayLabel.text = "--"
            
            updateTimer?.invalidate()
            tick = false
        }
    }
    
    func setupStartStopButton() {
        self.startStopButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        if let workDay = self.todaysWorkDay {
            if (workDay.timeStatus() == WorkDay.Status.Running) {
                self.startStopButton.backgroundColor = TimeTrackingColors.red()
                self.startStopButton.setTitle("STOP", forState: .Normal)
                self.startStopButton.enabled = true
            }
            else {
                self.startStopButton.backgroundColor = TimeTrackingColors.green()
                self.startStopButton.setTitle("START", forState: .Normal)
                self.startStopButton.enabled = true
            }
        }
        else {
            self.startStopButton.backgroundColor = TimeTrackingColors.darkGrey()
            self.startStopButton.enabled = false
        }
    }
    
    // Timer
    
    func startStopUpdateTimer() {
        if let workDay = self.todaysWorkDay {
            if (workDay.timeStatus() == WorkDay.Status.Running) {
                updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("setupLabels"), userInfo: nil, repeats: true)
            }
        }
        else {
            updateTimer?.invalidate()
            tick = false
            setupLabels()
        }
    }
    
    // Networking
    
    func fetchStatus() {
        self.startStopButton.enabled = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        APIClient.sharedInstance.status { (workDay, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.todaysWorkDay = workDay
            self.updateTimer?.invalidate()
            self.updateInterface()
        }
    }
    
    func performStart() {
        self.startStopButton.enabled = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        APIClient.sharedInstance.start { (workDay, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.todaysWorkDay = workDay
            self.updateInterface()
        }
    }
    
    func performStop() {
        self.startStopButton.enabled = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        APIClient.sharedInstance.stop { (workDay, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.todaysWorkDay = workDay
            self.updateInterface()
        }
    }
    
    // Actions
    
    @IBAction func pressedStartStop(sender: AnyObject) {
        if let workDay = self.todaysWorkDay {
            if (workDay.timeStatus() == WorkDay.Status.Running) {
                performStop()
            }
            else if (workDay.timeStatus() == WorkDay.Status.Stopped) {
                performStart()
            }
        }
        updateInterface()
    }
    
    @IBAction func refresh(sender: AnyObject) {
        fetchStatus()
    }
    
    @IBAction func pressedLogout(sender: UIBarButtonItem) {
        let controller = UIAlertController(title: "Logout", message: "Do you really want to logout?", preferredStyle: UIAlertControllerStyle.Alert)
        let logoutAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            if let loggedOut = self.loggedOut {
                loggedOut()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        controller.addAction(logoutAction)
        controller.addAction(cancelAction)
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
