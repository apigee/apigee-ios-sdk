//
//  APIClient.swift
//  Events
//
//  Created by Robert Walsh on 6/23/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

import Foundation

// ERROR: You will need to input your own application you will need to set the organizationID, applicationID and notifier name.
struct AppServicesStaticStrings {
    static let organizationID = "<Your organization ID>"
    static let applicationID = "<Your application ID or 'sandbox'>"
    static let pushNotificationNotifierName = "<Your push notification notifiers name>"
}

struct APIClientStaticStrings {
    static let type = "type"
    static let publicEventsCollection = "publicEvents"
    static let privateEventsCollection = "privateEvents"
    static let privateConnectionType = "private"
    static let usersConnectorType = "users"
    static let meConnectorID = "me"
    static let entitiesCollectionKey = "entities"
}

class APIClient : NSObject {

    let apigeeClient: ApigeeClient!

    var dataClient: ApigeeDataClient {
        return self.apigeeClient.dataClient()
    }
    var monitoringClient: ApigeeMonitoringClient {
        return self.apigeeClient.monitoringClient()
    }
    var currentUser: ApigeeUser? {
        return self.dataClient.getLoggedInUser()
    }

    init() {
        apigeeClient = ApigeeClient(organizationId: AppServicesStaticStrings.organizationID, applicationId: AppServicesStaticStrings.applicationID)
        super.init()
    }

    class func sharedClient() -> APIClient {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : APIClient? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = APIClient()
        }
        return Static.instance!
    }

    // MARK: Push Notificaiton Registration
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
        APIClient.sharedClient().dataClient.setDevicePushToken(deviceToken, forNotifier: AppServicesStaticStrings.pushNotificationNotifierName);
    }

    // MARK: Login/Logout user.
    func logoutCurrentUser() {
        if let user = self.currentUser {
            self.dataClient.logOut(user.username)
        }
    }

    func login(username: String?, password: String?, completion: ((Bool,String?) -> Void)?) {
        self.dataClient.logInUser(username, password: password, completionHandler: { response in
            if let completionBlock = completion {
                completionBlock(response.completedSuccessfully(),response.error)
            }
        })
    }

    // MARK: Creating/Registering a new user.
    func createUser(username: String?, fullName: String? ,email: String?, password: String?, completion: ((Bool,String?) -> Void)?) {
        self.dataClient.addUser(username, email: email, name: fullName, password: password, completionHandler: {[weak self] response in
            if response.completedSuccessfully() {
                self?.login(username, password: password, completion:completion)
            } else if let completionBlock = completion {
                completionBlock(false,response.rawResponse)
            }
        })
    }

    // MARK: Grabbing Public/Private Events
    func getPublicEvents(query: ApigeeQuery?) -> NSArray? {
        if let eventQuery = query {
            return self.dataClient.getCollection(APIClientStaticStrings.publicEventsCollection, usingQuery: query).list
        } else {
            return self.dataClient.getCollection(APIClientStaticStrings.publicEventsCollection).list
        }
    }

    func getPrivateEvents(query: ApigeeQuery?) -> NSArray? {
        var events: NSArray? = nil
        if let collection = self.dataClient.getEntityConnections(APIClientStaticStrings.usersConnectorType, connectorID:APIClientStaticStrings.meConnectorID, connectionType: APIClientStaticStrings.privateConnectionType, query: query).response as? NSDictionary {
            if let entities = collection[APIClientStaticStrings.entitiesCollectionKey] as? NSArray {
                events = entities
            }
        }
        return events
    }

    func getEvents(query: ApigeeQuery?) -> (publicEvents: NSArray?,privateEvents: NSArray?) {
        return (self.getPublicEvents(query),self.getPrivateEvents(query))
    }
}