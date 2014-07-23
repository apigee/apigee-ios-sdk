//
//  APIViewController.swift
//  Events
//
//  Created by Robert Walsh on 6/23/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

import Foundation
import UIKit

class APILoginViewController: UIViewController,UITextFieldDelegate,UIAlertViewDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    struct LoginViewControllerStaticStrings {
        static let eventsViewSequeIdentifier = "EventsView"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if( AppServicesStaticStrings.organizationID.bridgeToObjectiveC().isEqualToString("<Your organization ID>") || AppServicesStaticStrings.organizationID.bridgeToObjectiveC().isEqualToString("<Your application ID or 'sandbox'>") ) {
            UIAlertController.presentAlertController("Please input your application ID and/or organization name before using application!", message: nil, presentingController: self);
        }
    }

    // MARK: UITextFieldDelegate Functions
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Handling @IBOutlet touch events
    @IBAction func loginButtonPressed(sender: UIButton!) {
        let usernameText = self.usernameTextField.text
        let passwordText = self.passwordTextField.text
        if !usernameText.isEmpty && !passwordText.isEmpty {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                APIClient.sharedClient().login(usernameText, password: passwordText, completion: { loginSucceeded,errorMessage in
                    if loginSucceeded.getLogicValue() {
                        self.performSegueWithIdentifier(APILoginViewController.LoginViewControllerStaticStrings.eventsViewSequeIdentifier, sender: nil)
                    } else {
                        var alertTitle = "Failed"
                        var alertMessage = "Error: "
                        if let error = errorMessage {
                            alertMessage = alertMessage + error
                        }
                        UIAlertController.presentAlertController( alertTitle, message: alertMessage, presentingController: self)
                    }
                    })

                })
        } else {
            UIAlertController.presentAlertController( "Missing Credentials", message: "Username and/or Password is missing", presentingController: self)
        }
    }
}