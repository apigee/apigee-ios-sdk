//
//  ApigeeMonitoringOptions.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApigeeUploadListener.h"


@interface ApigeeMonitoringOptions : NSObject

@property(assign, nonatomic) BOOL monitoringEnabled;
@property(assign, nonatomic) BOOL crashReportingEnabled;
@property(assign, nonatomic) BOOL interceptNetworkCalls;
@property(assign, nonatomic) BOOL interceptNSURLSessionCalls;
@property(assign, nonatomic) BOOL autoPromoteLoggedErrors;
@property(assign, nonatomic) BOOL showDebuggingInfo;
@property(weak, nonatomic) id<ApigeeUploadListener> uploadListener;
@property(copy, nonatomic) NSString* customUploadUrl;

@end
