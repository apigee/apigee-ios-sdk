//
//  ApigeeViewController.h
//  MonitoringSample
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApigeeViewController : UIViewController <NSURLSessionDelegate,NSURLSessionDataDelegate>

- (IBAction)forceCrashPressed:(id)sender;
- (IBAction)generateLoggingEntryPressed:(id)sender;
- (IBAction)generateErrorPressed:(id)sender;
- (IBAction)captureNetworkPerformanceMetricsPressed:(id)sender;

- (IBAction)logLevelSettingChanged:(id)sender;
- (IBAction)errorLevelSettingChanged:(id)sender;

@end
