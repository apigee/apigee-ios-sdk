//
//  UIAlertController+ApigeeAdditions.swift
//  Events
//
//  Created by Robert Walsh on 6/26/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    class func presentAlertController(title: String?, message: String?, presentingController: UIViewController!) {
        if let viewController = presentingController {
            var alert = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
}