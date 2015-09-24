//
//  Login.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 10.03.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import UIKit

class LoginViewController: UITableViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var apiBaseUrlTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var loggedIn : (() -> Void)?
    
    class func loginNavigationController() -> UINavigationController {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        return storyboard.instantiateInitialViewController() as! UINavigationController
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PopoverSegue" {
            if let controller = segue.destinationViewController as? EndpointSelectionViewController {
                controller.popoverPresentationController!.delegate = self
                controller.didSelectEndpoint = { (endpoint : String) -> Void in
                    self.apiBaseUrlTextField.text = endpoint
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.loginButton.backgroundColor = TimeTrackingColors.green()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.apiBaseUrlTextField.text = Store.apiBaseUrl()
        self.emailTextField.text = Store.userIdentifier()
    }
    
    
    // MARK: Actions
    
    @IBAction func pressedLogin(sender: UIButton) {
        login()
    }
    
    func login() {
        self.persistUserData()
        self.startLoadingIndicator()
        
        APIClient.sharedInstance.setApiBaseUrl(Store.apiBaseUrl())
        
        APIClient.sharedInstance.login(self.emailTextField.text!, password: self.passwordTextField.text!) { (token, error) -> Void in
            self.stopLoadingIndicator()
            
            if let token = token {
                Store.setAuthenticationToken(token)
                
                if let loggedIn = self.loggedIn {
                    loggedIn()
                }
            }
            else {
                let alert = UIAlertController(title: "Login Failed", message: "There was a problem with login. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    
    // MARK: Helper
    
    func startLoadingIndicator() {
        self.activityIndicatorView.startAnimating()
        self.apiBaseUrlTextField.enabled = false
        self.emailTextField.enabled = false
        self.passwordTextField.enabled = false
        self.loginButton.hidden = true
    }
    
    func stopLoadingIndicator() {
        self.activityIndicatorView.stopAnimating()
        self.apiBaseUrlTextField.enabled = true
        self.emailTextField.enabled = true
        self.passwordTextField.enabled = true
        self.loginButton.hidden = false
    }
    
    func persistUserData() {
        Store.setApiBaseUrl(self.apiBaseUrlTextField.text!)
        Store.setUserIdentifier(self.emailTextField.text!)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField.isEqual(self.apiBaseUrlTextField)) {
            self.emailTextField.becomeFirstResponder()
        }
        else if (textField.isEqual(self.emailTextField)) {
            self.passwordTextField.becomeFirstResponder()
        }
        else if (textField.isEqual(self.passwordTextField)) {
            textField.resignFirstResponder()
            self.login()
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
}
