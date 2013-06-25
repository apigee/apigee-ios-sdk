//
//  ApigeeMonitoringOptions.m
//  InstaOpsAppMonitor
//
//  Created by Paul Dardeau on 5/20/13.
//  Copyright (c) 2013 InstaOps. All rights reserved.
//

#import "ApigeeMonitoringOptions.h"

@implementation ApigeeMonitoringOptions

@synthesize monitoringEnabled;
@synthesize crashReportingEnabled;
@synthesize interceptNetworkCalls;
@synthesize uploadListener;

- (id)init
{
    self = [super init];
    if( self )
    {
        self.monitoringEnabled = YES;
        self.crashReportingEnabled = YES;
        self.interceptNetworkCalls = YES;
        self.uploadListener = nil;
    }
    
    return self;
}

@end
