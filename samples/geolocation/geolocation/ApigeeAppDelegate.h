//
//  ApigeeAppDelegate.h
//  geolocation
//
//  Created by Alex Muramoto on 2/6/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ApigeeiOSSDK/Apigee.h>

@interface ApigeeAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
-(void)initializeSDKInAppDelegate:(NSString*)appName forOrg:(NSString*)orgName;
@property (strong, nonatomic) ApigeeClient *apigeeClient; //object for initializing the App Services SDK
@property (strong, nonatomic) ApigeeMonitoringClient *monitoringClient; //client object for Apigee App Monitoring methods
@property (strong, nonatomic) ApigeeDataClient *dataClient; //client object for App Services data methods
@end
