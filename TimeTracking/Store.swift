//
//  Store.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 09.03.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import Foundation

public class Store {
    
    private static let KeychainServiceKey = "com.bytepoets.TimeTracking"
    private static let KeychainAuthenticationTokenKey = "authenticationToken"
    private static let DefaultsApiBaseUrlKey = "apiBaseUrlKey"
    private static let DefaultsUserIdentifierKey = "userIdentifierKey"
    
    private static var cachedAuthenticationToken = ""
    
    public class func isLoggedIn() -> Bool {
        return Store.authenticationToken().characters.count > 0
    }
    
    public class func authenticationToken() -> String {
        var token: String
        if cachedAuthenticationToken.characters.count > 0 {
            token = cachedAuthenticationToken
        } else {
            token = retrieveTokenFromKeychain()
        }
        return token
    }
    
    public class func setAuthenticationToken(token: String) {
        let keychain = Keychain(service: KeychainServiceKey)
        keychain[KeychainAuthenticationTokenKey] = token
    }
    
    public class func clearAuthenticationToken() {
        let keychain = Keychain(service: KeychainServiceKey)
        keychain[KeychainAuthenticationTokenKey] = nil
        cachedAuthenticationToken = ""
    }
    
    private class func retrieveTokenFromKeychain() -> String {
        let keychain = Keychain(service: KeychainServiceKey)
        
        if let token = try? keychain.get(KeychainAuthenticationTokenKey) {
            if let unwrappedToken = token {
                return unwrappedToken
            }
        }
            
        return ""
    }
    
    public class func apiBaseUrl() -> String {
        if let apiBaseUrl = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsApiBaseUrlKey) as? String {
            return apiBaseUrl
        }
        else {
            return ""
        }
    }
    
    public class func setApiBaseUrl(apiBaseUrl: String) {
        NSUserDefaults.standardUserDefaults().setObject(apiBaseUrl, forKey: DefaultsApiBaseUrlKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public class func userIdentifier() -> String {
        if let userIdentifier = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsUserIdentifierKey) as? String {
            return userIdentifier
        }
        else {
            return ""
        }
    }
    
    public class func setUserIdentifier(userIdentifier: String) {
        NSUserDefaults.standardUserDefaults().setObject(userIdentifier, forKey: DefaultsUserIdentifierKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}