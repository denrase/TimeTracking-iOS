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
    
    var apiBaseUrl = Store.apiBaseUrl()
    var loginManager: Alamofire.Manager?
    var statusManager: Alamofire.Manager?
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
        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
        
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        defaultHeaders["Authorization"] = "Basic " + base64String!
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        
        self.loginManager = Alamofire.Manager(configuration: configuration)
    }
    
    private func setupStatusManager() {
        if (Store.isLoggedIn()) {
            var xHTTPAdditionalHeaders: [NSObject : AnyObject] = ["X-API-AUTH-TOKEN": Store.authenticationToken()]
            Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = xHTTPAdditionalHeaders
        
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders
            
            self.statusManager = Alamofire.Manager(configuration: configuration)
        }
    }
    
    // PUBLIC API
    
    public func login(email: String, password: String, completion: LoginResponse) {
        apiBaseUrl = Store.apiBaseUrl()
        setupLoginManager(email, pasword: password)
        self.loginManager?.request(.POST, "\(self.apiBaseUrl)/login")
            .authenticate(user: email, password: password)
            .responseJSON() { (request, response, json, error) in
                        
                let dict = json as? NSDictionary
                let token = dict?["token"] as? String
                        
                if let authorizationToken = token {
                    Store.setAuthenticationToken(authorizationToken)
                    self.setupStatusManager()
                }
                        
                completion(token: token, error: error)
            }
    }
    
    public func status(completion: StatusResponse) {
        apiBaseUrl = Store.apiBaseUrl()
        setupStatusManager()
        let status = "\(self.apiBaseUrl)/status"
        self.statusManager?.request(.GET, status)
            .responseJSON() { (request, response, json, error) in
                self.processRequest(completion, request: request, response: response, json: json, error: error)
            }
    }
    
    public func start(completion: StatusResponse) {
        apiBaseUrl = Store.apiBaseUrl()
        self.statusManager?.request(.POST, "\(self.apiBaseUrl)/status/start")
            .responseJSON() { (request, response, json, error) in
                self.processRequest(completion, request: request, response: response, json: json, error: error)
            }
    }
    
    public func stop(completion: StatusResponse) {
        apiBaseUrl = Store.apiBaseUrl()
        self.statusManager?.request(.POST, "\(self.apiBaseUrl)/status/stop")
            .responseJSON() { (request, response, json, error) in
                self.processRequest(completion, request: request, response: response, json: json, error: error)
            }
    }
    
    
    private func processRequest(completion: StatusResponse, request: NSURLRequest, response: NSHTTPURLResponse?, json: AnyObject?, error: NSError?) {
        let dict = json as? NSDictionary
        debugPrintln(dict)
        debugPrintln(request)
        
        if let status = dict?["status"] as? String {
            if let duration = dict?["duration"] as? String {
                if let pauseDuration = dict?["pause_duration"] as? String {
                    completion(workDay: WorkDay(status: status, worked: duration, paused: pauseDuration), error: nil)
                }
            }
        }
        else {
            debugPrintln(error)
            completion(workDay: nil, error: error);
        }
    }

}