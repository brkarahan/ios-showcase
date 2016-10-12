//
//  ViewController.swift
//  Showcase
//
//  Created by Burak Karahan on 10/06/16.
//  Copyright © 2016 Burak Karahan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var passwordField: MaterialTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbButtonPressed(sender: AnyObject) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"]) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                
//                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    
                
                    if error != nil {
                        print("Login failed! \(error)")
                    } else {
                        print("Logged in! \(user)")
                        
                        let userData = ["provider": credential.provider] //,"blah": "test"]
                        DataService.ds.createFirebaseUser(user!.uid, user: userData)
                        
                        NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func emailBtnPressed(sender: AnyObject) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            //DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
                
            
                if error != nil {
                    print(error)
                    
                    if error!.code == STATUS_ACCOUNT_NOTEXIST {
                        //DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                        
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating account. Try something else")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                                    
                                    let userData = ["provider": "email"]
                                    DataService.ds.createFirebaseUser(user!.uid, user: userData)
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        })
                    }else if error!.code == STATUS_INVALID_PASSWORD {
                        self.showErrorAlert("Could not login", msg: "Please check your username or password")
                    }
                    
                } else {
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password.")
        }
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}

