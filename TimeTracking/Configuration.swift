//
//  Configuration.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 27.06.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import Foundation

class Configuration {
    
    class func endpoints() -> Array<Endpoint> {
        var endpoints = [Endpoint]()
        
        if let endpointsData = Configuration.configuration()["endpoints"] as? Array<NSDictionary> {
            for endpointData: NSDictionary in endpointsData {
                if let name = endpointData["name"] as? String, url = endpointData["url"] as? String {
                    endpoints.append(Endpoint(name: name, url: url))
                }
            }
        }
        
        return endpoints
    }
    
    private class func configuration() -> NSDictionary {
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        return myDict!
    }
    
}