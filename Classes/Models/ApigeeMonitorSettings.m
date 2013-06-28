//
//  ApigeeMonitorSettings.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeMonitorSettings.h"

@implementation ApigeeMonitorSettings

@synthesize description;
@synthesize lastModifiedDate;
@synthesize urlRegex;
@synthesize networkMonitoringEnabled;
@synthesize logLevelToMonitor;
@synthesize enableLogMonitoring;
@synthesize customConfigParams;
@synthesize deletedCustomConfigParams;
@synthesize appConfigType;
@synthesize networkConfig;
@synthesize cachingEnabled;
@synthesize monitorAllUrls;
@synthesize sessionDataCaptureEnabled;
@synthesize batteryStatusCaptureEnabled;
@synthesize imeicaptureEnabled;
@synthesize obfuscateIMEI;
@synthesize deviceIdCaptureEnabled;
@synthesize obfuscateDeviceId;
@synthesize deviceModelCaptureEnabled;
@synthesize locationCaptureEnabled;
@synthesize locationCaptureResolution;
@synthesize networkCarrierCaptureEnabled;
@synthesize appConfigId;
@synthesize enableUploadWhenMobile;
@synthesize enableUploadWhenRoaming;
@synthesize agentUploadInterval;
@synthesize agentUploadIntervalInSeconds;
@synthesize samplingRate;

- (id) init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.networkMonitoringEnabled = YES;
    self.monitorAllUrls = YES;
    self.enableLogMonitoring = YES;
    self.logLevelToMonitor = 3;  // Debug
    self.sessionDataCaptureEnabled = YES;
    self.batteryStatusCaptureEnabled = YES;
    self.imeicaptureEnabled = YES;
    self.obfuscateIMEI = YES;
    self.deviceIdCaptureEnabled = YES;
    self.obfuscateDeviceId = YES;
    self.deviceModelCaptureEnabled = YES;
    self.locationCaptureEnabled = YES;
    self.locationCaptureResolution = 1L;
    self.networkCarrierCaptureEnabled = YES;
    self.enableUploadWhenRoaming = NO;
    self.enableUploadWhenMobile = YES; //This means not on wifi
    
    self.customConfigParams = [NSArray array];
    self.deletedCustomConfigParams = [NSArray array];
    self.urlRegex = [NSArray array];
    self.networkConfig = [[ApigeeNetworkConfig alloc] init];
    
    return self;
}
@end
