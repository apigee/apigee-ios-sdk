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

    @IBOutlet var cancelButton: UIButton
    @IBOutlet var registerButton: UIButton

    @IBOutlet var usernameTextField: UITextField
    @IBOutlet var fullNameTextField: UITextField
    @IBOutlet var emailTextField: UITextField
    @IBOutlet var passwordTextField: UITextField

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
                    self.dismissModalViewControllerAnimated(true)
                } else {
                    UIAlertController.presentAlertController(errorString, message: nil, presentingController: self)
                }
            })
        } else {
            UIAlertController.presentAlertController("All fields must be filled!", message: nil, presentingController: self)
        }
    }

    @IBAction func cancelButtonPressed(sender: AnyObject!) {
        self.dismissModalViewControllerAnimated(true)
    }
}