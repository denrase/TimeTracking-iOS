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
    
    private func setupLoginManager(user: String, pasword: String) {
        let plainString = "\(user):\(pasword)" as NSString
        let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        defaultHeaders["Authorization"] = "Basic " + base64String!
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        
        self.loginManager = Alamofire.Manager(configuration: configuration)
    }
    
    private func setupStatusManager() {
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        
        if (self.authenticationToken.characters.count > 0) {
            defaultHeaders["X-API-AUTH-TOKEN"] = self.authenticationToken
        }
        else {
            defaultHeaders.removeValueForKey("X-API-AUTH-TOKEN")
        }
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        self.statusManager = Alamofire.Manager(configuration: configuration)
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
    
    // ROUTES
    
    public func login(email: String, password: String, completion: LoginResponse) {
        setupLoginManager(email, pasword: password)
        self.loginManager?.request(.POST, "\(self.apiBaseUrl)/login")
            .authenticate(user: email, password: password)
            .responseJSON { _, _, result in
                        
                if let dict = result.value as? NSDictionary, token = dict["token"] as? String {
                    self.setAuthenticationToken(token)
                    completion(token: token, error: nil)
                }
                else {
                    let error = NSError(domain: "", code: -1, userInfo: nil)
                    completion(token: nil, error: error)
                }
            }
    }
    
    public func status(completion: StatusResponse) {
        let status = "\(self.apiBaseUrl)/status"
        self.statusManager?.request(.GET, status)
            .responseJSON { _, response, result in
                self.processRequest(completion, result: result)
            }
    }
    
    public func start(completion: StatusResponse) {
        self.statusManager?.request(.POST, "\(self.apiBaseUrl)/status/start")
            .responseJSON { _, response, result in
                self.processRequest(completion, result: result)
        }
    }
    
    public func stop(completion: StatusResponse) {
        self.statusManager?.request(.POST, "\(self.apiBaseUrl)/status/stop")
            .responseJSON { _, response, result in
                self.processRequest(completion, result: result)
        }
    }
    
    private func processRequest(completion: StatusResponse, result: Result<AnyObject>) {
        let dict = result.value as? NSDictionary
        
        if let status = dict?["status"] as? String, duration = dict?["duration"] as? String, pauseDuration = dict?["pause_duration"] as? String {
             completion(workDay: WorkDay(status: status, worked: duration, paused: pauseDuration), error: nil)
        }
        else {
            let error = NSError(domain: "", code: -1, userInfo: nil)
            completion(workDay: nil, error: error);
        }
    }

}