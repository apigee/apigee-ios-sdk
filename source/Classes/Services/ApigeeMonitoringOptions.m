//
//  ApigeeMonitoringOptions.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeMonitoringOptions.h"

@implementation ApigeeMonitoringOptions

@synthesize monitoringEnabled;
@synthesize crashReportingEnabled;
@synthesize interceptNetworkCalls;
@synthesize interceptNSURLSessionCalls;
@synthesize autoPromoteLoggedErrors;
@synthesize showDebuggingInfo;
@synthesize uploadListener;
@synthesize customUploadUrl;
@synthesize performAutomaticUIEventTracking;
@synthesize alwaysUploadCrashReports;

- (id)init
{
    self = [super init];
    if( self )
    {
        self.monitoringEnabled = YES;
        self.crashReportingEnabled = YES;
        self.interceptNetworkCalls = YES;
        self.interceptNSURLSessionCalls = NO;
        self.autoPromoteLoggedErrors = YES;
        self.showDebuggingInfo = NO;
        self.uploadListener = nil;
        self.customUploadUrl = nil;
        self.performAutomaticUIEventTracking = NO;
        self.alwaysUploadCrashReports = YES;
    }
    
    return self;
}

@end
