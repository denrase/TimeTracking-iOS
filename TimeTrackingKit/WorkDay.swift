//
//  WorkStatus.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 14.03.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import Foundation

public struct WorkDay {
    
    public enum Status: String {
        case Running = "running"
        case Stopped = "stopped"
        case Unknown = "Unknown"
    }
    
    var status: Status = .Unknown
    var startDate: NSDate = NSDate()
    var paused: String = "00:00"
    
    public init(status: String, worked: String, paused: String) {
        self.status = timeStatusForStatusString(status)
        
        let hoursAndMinutes = scanHoursAndMinutes(worked)
        let seconds = Double(-hoursAndMinutes.0) * 60.0 * 60.0 - Double(hoursAndMinutes.1) * 60.0
        self.startDate = NSDate(timeIntervalSinceNow: seconds)
        
        self.paused = paused;
    }
    
    public func todaysStartDate() -> NSDate {
        return startDate
    }
    
    public func timeStatus() -> Status {
        return self.status
    }
    
    public func workedHoursAndMinutesToday() -> (Int, Int) {
        var calendar = NSCalendar.currentCalendar()
        let flags: NSCalendarUnit = NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute
        let now = NSDate()
        let components = calendar.components(flags, fromDate: self.startDate, toDate: now, options: nil)
        return (components.hour, components.minute)
    }
    
    public func pausedHoursAndMinutesToday() -> (Int, Int) {
        return scanHoursAndMinutes(self.paused)
    }
    
    private func timeStatusForStatusString(status: String) -> Status {
        var timeStatus = Status.Unknown
        
            switch(status) {
            case Status.Running.rawValue:
                timeStatus = Status.Running
            case Status.Stopped.rawValue:
                timeStatus = Status.Stopped
            case Status.Unknown.rawValue:
                timeStatus = Status.Unknown
            default:
                timeStatus = Status.Unknown
            }
        
        return timeStatus
    }
    
    // Helper
    
    private func scanHoursAndMinutes(input: String) -> (Int, Int) {
        let timeScanner = NSScanner(string: input);
        var hours = 0
        var minutes = 0
        timeScanner.scanInteger(&hours)
        timeScanner.scanString(":", intoString: nil) //jump over :
        timeScanner.scanInteger(&minutes)
        
        return (hours, minutes)
    }
}