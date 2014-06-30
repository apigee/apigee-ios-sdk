//
//  APIAddEventViewController.swift
//  Events
//
//  Created by Robert Walsh on 6/25/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

import Foundation
import UIKit

class APIAddEventViewController: UIViewController {

    @IBOutlet var eventNameTextField: UITextField
    @IBOutlet var cityTextField: UITextField
    @IBOutlet var stateTextField: UITextField
    @IBOutlet var publicSwitch: UISwitch

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func addEvent() {
        CLGeocoder().geocodeAddressString(self.cityTextField.text + ", " + self.stateTextField.text, completionHandler: { placemarks,error in
            if error == nil && placemarks.count > 0 {
                if let placemark = placemarks[0] as? CLPlacemark {
                    let latitude = NSNumber(double: placemark.location.coordinate.latitude)
                    let longitude = NSNumber(double: placemark.location.coordinate.longitude)


                    var eventEntityDict = Dictionary<String,AnyObject>()
                    eventEntityDict[APIClientStaticStrings.type] = (self.publicSwitch.on) ? APIClientStaticStrings.publicEventsCollection : APIClientStaticStrings.privateEventsCollection
                    eventEntityDict[EventAttributeNames.eventName] = self.eventNameTextField.text
                    eventEntityDict[EventAttributeNames.location] = [EventAttributeNames.latitude:latitude,EventAttributeNames.longitude:longitude]

                    let response = APIClient.sharedClient().dataClient.createEntity(eventEntityDict)
                    if response.completedSuccessfully() {
                        if !self.publicSwitch.on {
                            if let responseEntity = response.firstEntity() {
                                APIClient.sharedClient().dataClient.connectEntities(APIClientStaticStrings.usersConnectorType, connectorID: APIClient.sharedClient().currentUser!.uuid, type: APIClientStaticStrings.privateConnectionType, connecteeID: responseEntity.uuid)
                            }
                        }
                    }
                    self.navigationController.popViewControllerAnimated(true)
                }
            } else {
                UIAlertController.presentAlertController("Location Invalid!", message: error.description, presentingController: self)
            }
        })
    }

    @IBAction func addEventPressed(sender: UIButton!) {
        if !eventNameTextField.text.isEmpty && !cityTextField.text.isEmpty && !stateTextField.text.isEmpty {
            self.addEvent()
        } else {
            UIAlertController.presentAlertController( "All fields must be filled!", message: nil, presentingController: self)
        }
    }

    @IBAction func cancelPressed(sender: AnyObject!) {
        self.navigationController.popViewControllerAnimated(true)
    }
}