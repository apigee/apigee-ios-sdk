//
//  ApigeeViewController.h
//  MonitoringSample
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApigeeViewController : UIViewController
#ifdef __IPHONE_7_0
<NSURLSessionDelegate,NSURLSessionDataDelegate>
#endif

- (IBAction)forceCrashPressed:(id)sender;
- (IBAction)generateLoggingEntryPressed:(id)sender;
- (IBAction)generateErrorPressed:(id)sender;
- (IBAction)captureNetworkPerformanceMetricsPressed:(id)sender;

- (IBAction)logLevelSettingChanged:(id)sender;
- (IBAction)errorLevelSettingChanged:(id)sender;

@end
