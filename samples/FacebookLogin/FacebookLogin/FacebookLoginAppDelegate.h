//
//  FacebookLoginAppDelegate.h
//  FacebookLogin
//
//  Created by Jeremy Anticouni on 7/16/14
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ApigeeiOSSDK/Apigee.h>

@interface FacebookLoginAppDelegate : UIResponder <UIApplicationDelegate>

// Object for initializing the App Services SDK
@property (strong, nonatomic) ApigeeClient *apigeeClient;

// Client object for Apigee App Monitoring methods
@property (strong, nonatomic) ApigeeMonitoringClient *monitoringClient;

// Client object for App Services data methods
@property (strong, nonatomic) ApigeeDataClient *dataClient;

@property (strong, nonatomic) UIWindow *window;

@end
