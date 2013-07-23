//
//  ApigeeCompositeConfiguration+Initiailizers.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeLogger.h"
#import "ApigeeNetworkConfig.h"
#import "ApigeeMonitorSettings.h"
#import "ApigeeCompositeConfiguration+Initializers.h"

#define kApigeeDefaultUploadInterval 60 
#define kApigeeDefaultSampleRate 100 

@implementation ApigeeCompositeConfiguration (Initializers)

+ (ApigeeCompositeConfiguration *) defaultConfiguration
{
    ApigeeCompositeConfiguration *configuration = [[ApigeeCompositeConfiguration alloc] init];
    
    configuration.defaultSettings = [[ApigeeMonitorSettings alloc] init];
    configuration.defaultSettings.networkConfig = [[ApigeeNetworkConfig alloc] init];
    
    configuration.defaultSettings.agentUploadInterval = kApigeeDefaultUploadInterval * 1000;
    configuration.defaultSettings.agentUploadIntervalInSeconds = kApigeeDefaultUploadInterval;
    configuration.defaultSettings.samplingRate = kApigeeDefaultSampleRate;
    configuration.defaultSettings.logLevelToMonitor = kApigeeLogLevelError;
    
    configuration.ABTestingOverrideEnabled = NO;
    configuration.deviceTypeOverrideEnabled = NO;
    configuration.deviceLevelOverrideEnabled = NO;
    
    configuration.lastModifiedDate = [NSDate distantPast];
    configuration.defaultSettings.lastModifiedDate = [NSDate distantPast];
    configuration.defaultSettings.locationCaptureEnabled = NO;
    
    return configuration;

}
@end
