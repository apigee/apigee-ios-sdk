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

    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var publicSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func addEvent() {

        let eventName = eventNameTextField.text
        var addressString = ""
        if let cityText = self.cityTextField?.text {
            addressString = cityText
        }

        if let stateText = self.stateTextField?.text {
            if addressString.isEmpty {
                addressString = stateText
            } else {
                addressString += " ," + stateText
            }
        }

        if !eventName.isEmpty && !addressString.isEmpty {
            let isPublicEvent = publicSwitch.on
            CLGeocoder().geocodeAddressString(addressString, completionHandler: { placemarks,error in
                if error == nil && placemarks.count > 0 {
                    if let placemark = placemarks[0] as? CLPlacemark {
                        let latitude = NSNumber(double: placemark.location.coordinate.latitude)
                        let longitude = NSNumber(double: placemark.location.coordinate.longitude)

                        var eventEntityDict = Dictionary<String,AnyObject>()
                        if isPublicEvent {
                            eventEntityDict[APIClientStaticStrings.type] = APIClientStaticStrings.publicEventsCollection
                        } else {
                            eventEntityDict[APIClientStaticStrings.type] = APIClientStaticStrings.privateEventsCollection
                        }

                        eventEntityDict[EventAttributeNames.eventName] = eventName
                        eventEntityDict[EventAttributeNames.location] = [EventAttributeNames.latitude:latitude,EventAttributeNames.longitude:longitude]

                        let response = APIClient.sharedClient().dataClient.createEntity(eventEntityDict)
                        if response.completedSuccessfully() && !isPublicEvent {
                            if let responseEntity = response.firstEntity() {
                                APIClient.sharedClient().dataClient.connectEntities(APIClientStaticStrings.usersConnectorType, connectorID: APIClient.sharedClient().currentUser!.uuid, type: APIClientStaticStrings.privateConnectionType, connecteeID: responseEntity.uuid)
                            }
                        }
                        self.navigationController!.popViewControllerAnimated(true)
                    }
                } else {
                    UIAlertController.presentAlertController("Location Invalid!", message: error.description, presentingController: self)
                }
            })
        } else {
            UIAlertController.presentAlertController("Event Name or Location Invalid!", message: "Please specify an event name and/or location.", presentingController: self)
        }
    }

    @IBAction func addEventPressed(sender: UIButton!) {
        if !eventNameTextField.text.isEmpty && !cityTextField.text.isEmpty && !stateTextField.text.isEmpty {
            self.addEvent()
        } else {
            UIAlertController.presentAlertController( "All fields must be filled!", message: nil, presentingController: self)
        }
    }

    @IBAction func cancelPressed(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true)
    }
}