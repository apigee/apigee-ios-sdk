//
//  APIEventsViewController.swift
//  Events
//
//  Created by Robert Walsh on 6/25/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct EventAttributeNames {
    static let eventName = "eventName"
    static let location = "location"
    static let latitude = "latitude"
    static let longitude = "longitude"
}

struct EventsViewControllerStaticStrings {
    static let cellIdentifier = "APIEventCollectionViewCellIdentifier"
    static let sectionHeaderIdentifier = "APICollectionViewSectionHeader"
    static let publicEventsHeader = "Public Events"
    static let privateEventsHeader = "Private Events"
}

class APIEventsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var locationBasedSearchSwitch: UISwitch!
    @IBOutlet weak var eventSearchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    var publicEvents: NSArray?
    var privateEvents: NSArray?

    // MARK: UIViewController Functions
    override func viewWillAppear(animated: Bool) {
        self.fetchEvents(nil,reloadCollectionView: true)
        self.eventSearchBar.text = nil
        super.viewWillAppear(animated)
    }

    // MARK: Handling @IBOutlet touch events
    @IBAction func logoutButtonPressed(sender: AnyObject!) {
        APIClient.sharedClient().logoutCurrentUser()
        self.navigationController!.popViewControllerAnimated(true)
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar!) {
        self.fetchEvents(nil,reloadCollectionView: true)
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar!) -> Bool {
        if locationBasedSearchSwitch.on {
            self.performLocationBasedSearch(searchBar.text)
        } else {
            self.performEventNameBasedSearch(searchBar.text)
        }
        searchBar.resignFirstResponder()
        return true
    }

    // MARK: Performing queries
    func fetchEvents(query: ApigeeQuery?,reloadCollectionView: Bool) {
        let publicAndPrivateEvents = APIClient.sharedClient().getEvents(query)
        self.publicEvents = publicAndPrivateEvents.publicEvents
        self.privateEvents = publicAndPrivateEvents.privateEvents
        if reloadCollectionView == true {
            self.collectionView.reloadData()
        }
    }

    func performLocationBasedSearch(searchText: String) {
        CLGeocoder().geocodeAddressString(searchText, completionHandler: { placemarks,error in
            if error == nil && placemarks.count > 0 {
                if let placemark = placemarks[0] as? CLPlacemark {
                    var query = ApigeeQuery()
                    query.addRequiredWithinLocation(EventAttributeNames.location, location: placemark.location, distance: 160000)
                    self.fetchEvents(query,reloadCollectionView: true)
                } else {
                    self.publicEvents = nil
                    self.privateEvents = nil
                    self.collectionView.reloadData()
                }
            }})
    }

    func performEventNameBasedSearch(searchText: String) {
        var query = ApigeeQuery()
        var words = searchText.componentsSeparatedByString(" ")
        for word in words {
            query.addRequiredContains(EventAttributeNames.eventName, value: word + "*")
        }
        self.fetchEvents(query,reloadCollectionView: true)
    }


    // MARK: UICollectinoViewDataSouce/UICollectinoViewDelegate Functions
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 2
    }

    func collectionView(collectionView: UICollectionView!, viewForSupplementaryElementOfKind kind: String!, atIndexPath indexPath: NSIndexPath!) -> UICollectionReusableView! {

        let sectionHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: EventsViewControllerStaticStrings.sectionHeaderIdentifier, forIndexPath: indexPath) as APICollectionViewSectionHeader

        if indexPath.section == 0 {
            sectionHeader.headerNameLabel.text = EventsViewControllerStaticStrings.publicEventsHeader
        } else {
            sectionHeader.headerNameLabel.text = EventsViewControllerStaticStrings.privateEventsHeader
        }

        return sectionHeader
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if let publicEvents = self.publicEvents {
                return publicEvents.count
            } else {
                return 0
            }
        } else if let privateEvents = self.privateEvents {
            return privateEvents.count
        } else {
            return 0
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EventsViewControllerStaticStrings.cellIdentifier, forIndexPath: indexPath) as APIEventCollectionViewCell

        var eventList: NSArray? = nil
        if indexPath.section == 0 {
            eventList = self.publicEvents
        } else {
            eventList = self.privateEvents
        }

        if eventList?.count > indexPath.row {
            if let event : AnyObject = eventList?[indexPath.row] {

                var eventName: String? = nil
                var eventLocationDictionary: NSDictionary? = nil
                if let eventConnectionDict = event as? NSDictionary {
                    eventName = eventConnectionDict[EventAttributeNames.eventName] as? String
                    eventLocationDictionary = eventConnectionDict[EventAttributeNames.location] as? NSDictionary
                } else if let eventEntity = event as? ApigeeEntity {
                    eventName = eventEntity.getStringProperty(EventAttributeNames.eventName)
                    eventLocationDictionary = eventEntity.getObjectProperty(EventAttributeNames.location) as? NSDictionary
                }

                cell.eventNameLabel.text = eventName
                cell.locationLabel.text = nil
                
                if let locationDict = eventLocationDictionary {
                    var lat = locationDict[EventAttributeNames.latitude] as? NSNumber
                    var long = locationDict[EventAttributeNames.longitude] as? NSNumber
                    if lat != nil && long != nil {
                        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: lat!.doubleValue, longitude: long!.doubleValue), completionHandler: {placemarks,error in
                            if error == nil && placemarks.count > 0 {
                                if let placemark = placemarks[0] as? CLPlacemark {
                                    cell.locationLabel.text = placemark.locality + ", " + placemark.administrativeArea
                                }
                            }})
                    }
                }
            }
        }

        return cell
    }

}