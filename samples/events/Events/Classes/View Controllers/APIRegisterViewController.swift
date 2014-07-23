//
//  APIRegisterViewController.swift
//  Events
//
//  Created by Robert Walsh on 6/25/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

import Foundation
import UIKit

class APIRegisterViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: UITextFieldDelegate Functions
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: Handling @IBOutlet touch events
    @IBAction func registerButtonPressed(sender: AnyObject!) {

        let username = self.usernameTextField.text
        let fullName = self.fullNameTextField.text
        let email = self.emailTextField.text
        let password = self.passwordTextField.text

        if !username.isEmpty && !fullName.isEmpty && !email.isEmpty && !password.isEmpty {
            APIClient.sharedClient().createUser(username, fullName:fullName, email:email, password:password, completion:{ didSucceed,errorString in
                if didSucceed {
                    self.dismissViewControllerAnimated(true, completion: nil);
                } else {
                    UIAlertController.presentAlertController(errorString, message: nil, presentingController: self)
                }
            })
        } else {
            UIAlertController.presentAlertController("All fields must be filled!", message: nil, presentingController: self)
        }
    }

    @IBAction func cancelButtonPressed(sender: AnyObject!) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
}