//
//  ApigeeMonitorSettings+JSON.m
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 9/18/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeJSONConfigKeys.h"
#import "NSDate+Apigee.h"
#import "ApigeeCustomConfigParam.h"
#import "ApigeeNetworkConfig.h"
#import "ApigeeCustomConfigParam+JSON.h"
#import "ApigeeNetworkConfig+JSON.h"
#import "ApigeeMonitorSettings+JSON.h"

@implementation ApigeeMonitorSettings (JSON)

+ (ApigeeMonitorSettings *) fromDictionary:(NSDictionary *) jsonObjects
{
    ApigeeMonitorSettings *settings = [[ApigeeMonitorSettings alloc] init];    
    
    settings.appConfigId = [[jsonObjects objectForKey:kAppConfigOverrideAppConfigId] integerValue];
    settings.appConfigType = [jsonObjects objectForKey:kAppConfigOverrideConfigType];
    settings.description = [jsonObjects objectForKey:kAppConfigOverrideDescription];
    
    NSNumber *lastModified = (NSNumber*)[jsonObjects objectForKey:kAppConfigOverrideLastModifiedDate];    
    
    if (![lastModified isEqual:[NSNull null]]) {
        settings.lastModifiedDate = [NSDate dateFromMilliseconds:[lastModified unsignedLongLongValue]];
    }
    
    settings.urlRegex = [jsonObjects objectForKey:kAppConfigOverrideUrlRegex];
    settings.networkMonitoringEnabled = [[jsonObjects objectForKey:kAppConfigOverrideEnableNetworkMonitor] boolValue];
    settings.logLevelToMonitor = [[jsonObjects objectForKey:kAppConfigOverrideLogLevel] integerValue];
    settings.enableLogMonitoring = [[jsonObjects objectForKey:kAppConfigOverrideEnableLogMonitor] boolValue];
    settings.customConfigParams = [ApigeeCustomConfigParam transformArray:[jsonObjects objectForKey:kAppConfigOverrideCustomParams]];
    settings.networkConfig = [ApigeeNetworkConfig fromDictionary:[jsonObjects objectForKey:kAppConfigOverrideNetowrkConfig]];
    settings.cachingEnabled = [[jsonObjects objectForKey:kAppConfigOverrideEnableCaching] boolValue];
    settings.monitorAllUrls = [[jsonObjects objectForKey:kAppConfigOverrideMonitorAllUrls] boolValue];
    settings.sessionDataCaptureEnabled = [[jsonObjects objectForKey:kAppConfigOverrideCaptureSessionMetrics] boolValue];
    settings.batteryStatusCaptureEnabled = [[jsonObjects objectForKey:kAppConfigOverrideCaptureBatterStatus] boolValue];
    settings.imeicaptureEnabled = [[jsonObjects objectForKey:kAppConfigOverrideCaptureIMEI] boolValue];
    settings.obfuscateIMEI = [[jsonObjects objectForKey:kAppConfigOverrideObfuscateIMEI] boolValue];
    settings.deviceIdCaptureEnabled = [[jsonObjects objectForKey:kAppConfigOverrideCaptureDeviceId] boolValue];
    settings.locationCaptureEnabled = [[jsonObjects objectForKey:kAppConfigOverrideCaptureLocation] boolValue];
    settings.locationCaptureResolution = [[jsonObjects objectForKey:kAppConfigOverrideCaptureLocationResolution] integerValue];
    settings.networkCarrierCaptureEnabled = [[jsonObjects objectForKey:kAppConfigOverrideCaptureNetworkCarrier] boolValue];
    settings.deviceModelCaptureEnabled = [[jsonObjects objectForKey:kAppConfigOverrideCaptureDeviceModel] boolValue];

    settings.enableUploadWhenRoaming = [[jsonObjects objectForKey:kAppConfigOverrideUploadWhenRoaming] boolValue];
    settings.enableUploadWhenMobile = [[jsonObjects objectForKey:kAppConfigOverrideUploadWhenMobile] boolValue];

    settings.agentUploadInterval = [[jsonObjects objectForKey:kAppConfigOverrideUploadInterval] integerValue];
    settings.agentUploadIntervalInSeconds = [[jsonObjects objectForKey:kAppConfigOverrideUploadIntervalSeconds] integerValue];
    settings.samplingRate = [[jsonObjects objectForKey:kAppConfigOverrideSampleRate] integerValue];
    
    return settings;
}

@end
