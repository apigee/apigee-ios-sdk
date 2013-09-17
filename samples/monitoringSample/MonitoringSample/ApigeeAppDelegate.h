//
//  ApigeeAppDelegate.h
//  MonitoringSample
//
//  Created by Paul Dardeau on 9/4/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApigeeClient;

@interface ApigeeAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ApigeeClient* apigeeClient;

@end
