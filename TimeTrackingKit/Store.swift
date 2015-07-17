//
//  Store.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 09.03.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import Foundation

public class Store {
    
    static let AppGroup = "group.com.bytepoets.timetracking"
    static let ApiBaseUrlKey = "apiBaseUrlKey"
    static let UserIdentifierKey = "userIdentifierKey"
    static let TokenKeychainItem = "TokenKeychainItem"
    static var cachedAuthenticationToken: String?
    
    public class func isLoggedIn() -> Bool {
        return count(Store.authenticationToken()) > 0
    }
    
    public class func authenticationToken() -> String {
        var token: String
        if let cachedToken = cachedAuthenticationToken {
            token = cachedToken
        } else {
            token = retrieveTokenFromKeychain()
        }
        return token
    }
    
    private class func retrieveTokenFromKeychain() -> String {
        let tokenKeychainItem = KeychainItemWrapper(identifier: Store.TokenKeychainItem, accessGroup: Store.AppGroup)
        let tokenData = tokenKeychainItem.objectForKey(kSecValueData) as! NSData!
        let tokenString = NSString(data: tokenData, encoding: NSUTF8StringEncoding)
        
        switch(tokenString) {
        case .Some(let token):
            return String(token)
        default:
            return ""
        }
    }
    
    public class func resetKeychain() {
        let tokenKeychainItem = KeychainItemWrapper(identifier: Store.TokenKeychainItem, accessGroup: Store.AppGroup)
        tokenKeychainItem.resetKeychainItem()
    }
    
    public class func setAuthenticationToken(token: String) {
        let tokenKeychainItem = KeychainItemWrapper(identifier: Store.TokenKeychainItem, accessGroup: Store.AppGroup)
        tokenKeychainItem.setObject(token, forKey: kSecValueData)
    }
    
    public class func apiBaseUrl() -> String {
        if let apiBaseUrl = Store.sharedDefaults().objectForKey(Store.ApiBaseUrlKey) as? String {
            return apiBaseUrl
        }
        else {
            return ""
        }
    }
    
    public class func setApiBaseUrl(apiBaseUrl: String) {
        Store.sharedDefaults().setObject(apiBaseUrl, forKey: Store.ApiBaseUrlKey)
        Store.sharedDefaults().synchronize()
    }
    
    public class func userIdentifier() -> String {
        if let userIdentifier = Store.sharedDefaults().objectForKey(Store.UserIdentifierKey) as? String {
            return userIdentifier
        }
        else {
            return ""
        }
    }
    
    public class func setUserIdentifier(userIdentifier: String) {
        Store.sharedDefaults().setObject(userIdentifier, forKey: Store.UserIdentifierKey)
        Store.sharedDefaults().synchronize()
    }
    
    //MARK: Helper
    
    private class func sharedDefaults() -> NSUserDefaults {
        let defaults = NSUserDefaults(suiteName: Store.AppGroup)!
        return defaults;
    }
}