//
//  UsersAppDelegate.h
//  UsersAndGroups
//
//  Created by Steve Traut on 12/27/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersApiClient.h"
//#import <ApigeeiOSSDK/Apigee.h>

@interface UsersAppDelegate : UIResponder <UIApplicationDelegate>

//object for initializing the App Services SDK
@property (strong, nonatomic) ApigeeClient *apigeeClient;

//client object for Apigee App Monitoring methods
@property (strong, nonatomic) ApigeeMonitoringClient *monitoringClient;

//client object for App Services data methods
@property (strong, nonatomic) ApigeeDataClient *dataClient;

@property (strong, nonatomic) UsersApiClient *apiClient;
@property (strong, nonatomic) UIWindow *window;

@end
