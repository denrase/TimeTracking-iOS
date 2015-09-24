//
//  Login.swift
//  TimeTracking
//
//  Created by Denis Andrasec on 10.03.15.
//  Copyright (c) 2015 Bytepoets. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var apiBaseUrlTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    // MARK: Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)!.CGRectValue()
        
        var inset = self.scrollView.contentInset
        inset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = inset
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var inset = self.scrollView.contentInset
        inset.bottom = 0
        self.scrollView.contentInset = inset
    }
    
    // MARK: Actions
    
    @IBAction func pressedLogin(sender: AnyObject?) {
        self.persistUserData()
        self.startLoadingIndicator()
        
        APIClient.sharedInstance.setApiBaseUrl(Store.apiBaseUrl())
        
        APIClient.sharedInstance.login(self.emailTextField.text!, password: self.passwordTextField.text!) { (token, error) -> Void in
            self.stopLoadingIndicator()
            
            if let token = token {
                Store.setAuthenticationToken(token)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Login Failed", message: "There was a problem with login. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pressedCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helper
    
    func startLoadingIndicator() {
        self.activityIndicatorView.startAnimating()
        self.apiBaseUrlTextField.enabled = false
        self.emailTextField.enabled = false
        self.passwordTextField.enabled = false
        self.loginButton.enabled = false
    }
    
    func stopLoadingIndicator() {
        self.activityIndicatorView.stopAnimating()
        self.apiBaseUrlTextField.enabled = true
        self.emailTextField.enabled = true
        self.passwordTextField.enabled = true
        self.loginButton.enabled = true
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
            self.pressedLogin(nil)
        }
        
        return true
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
}
