//
//  APIClient.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 09.03.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import Foundation
import Alamofire

public class APIClient {
    
    private var apiBaseUrl = ""
    private var authenticationToken = ""
    
    private var loginManager: Alamofire.Manager?
    private var statusManager: Alamofire.Manager?
    
    public typealias LoginResponse = (token: String?, error: NSError?) -> Void
    public typealias StatusResponse = (workDay: WorkDay?, error: NSError?) -> Void
    
    public class var sharedInstance: APIClient {
        struct Static {
            static let instance: APIClient = APIClient()
        }
        return Static.instance
    }
    
    // SETUP
    
    private init () {
        setupStatusManager()
    }
    
    private func setupStatusManager() {
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        
        if (self.authenticationToken.characters.count > 0) {
            defaultHeaders["X-API-AUTH-TOKEN"] = self.authenticationToken
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = defaultHeaders
            self.statusManager = Alamofire.Manager(configuration: configuration)
        }
        else {
            defaultHeaders.removeValueForKey("X-API-AUTH-TOKEN")
            self.statusManager = nil
        }
    }
    
    // -- PUBLIC API ---
    
    // SETTER/GETTER
    
    public func setApiBaseUrl(apiBaseUrl: String) {
        self.apiBaseUrl = apiBaseUrl
    }
    
    public func setAuthenticationToken(authenticationToken: String) {
        self.authenticationToken = authenticationToken
        setupStatusManager()
    }
    
    public func clearAuthenticationToken() {
        self.authenticationToken = "";
        setupStatusManager()
    }
    
    // ROUTES
    
    public func login(email: String, password: String, completion: LoginResponse) {
        let plainString = "\(email):\(password)" as NSString
        let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        let header = ["Authorization": "Basic " + base64String!]
        let route = "\(self.apiBaseUrl)/login"
        
        Alamofire.request(.POST, route, headers: header).responseJSON { response in
            if let json = response.result.value as? NSDictionary, token = json["token"] as? String {
                self.setAuthenticationToken(token)
                completion(token: token, error: nil)
            } else {
                let error = NSError(domain: "", code: -1, userInfo: nil)
                completion(token: nil, error: error)
            }
        }
    }
    
    public func status(completion: StatusResponse) {
        let header = ["X-API-AUTH-TOKEN": self.authenticationToken]
        let route = "\(self.apiBaseUrl)/status"
        Alamofire.request(.GET, route, headers: header).responseJSON { response in
            self.processRequest(completion, result: response.result.value)
        }
    }
    
    public func start(completion: StatusResponse) {
        let header = ["X-API-AUTH-TOKEN": self.authenticationToken]
        let route = "\(self.apiBaseUrl)/status/start"
        Alamofire.request(.POST, route, headers: header).responseJSON { response in
            self.processRequest(completion, result: response.result.value)
        }
    }
    
    public func stop(completion: StatusResponse) {
        let header = ["X-API-AUTH-TOKEN": self.authenticationToken]
        let route = "\(self.apiBaseUrl)/status/stop"
        Alamofire.request(.POST, route, headers: header).responseJSON { response in
            self.processRequest(completion, result: response.result.value)
        }
    }
    
    private func processRequest(completion: StatusResponse, result: AnyObject?) {
        if let dict = result as? NSDictionary, status = dict["status"] as? String, duration = dict["duration"] as? String, pauseDuration = dict["pause_duration"] as? String {
            completion(workDay: WorkDay(status: status, worked: duration, paused: pauseDuration), error: nil)
        }
        else {
            let error = NSError(domain: "", code: -1, userInfo: nil)
            completion(workDay: nil, error: error);
        }
    }

}