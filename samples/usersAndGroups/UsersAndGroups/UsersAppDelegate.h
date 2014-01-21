//
//  UsersAppDelegate.h
//  UsersAndGroups
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ApigeeiOSSDK/Apigee.h>

@interface UsersAppDelegate : UIResponder <UIApplicationDelegate>

// Object for initializing the App Services SDK
@property (strong, nonatomic) ApigeeClient *apigeeClient;

// Client object for Apigee App Monitoring methods
@property (strong, nonatomic) ApigeeMonitoringClient *monitoringClient;

// Client object for App Services data methods
@property (strong, nonatomic) ApigeeDataClient *dataClient;

@property (strong, nonatomic) UIWindow *window;

@end
