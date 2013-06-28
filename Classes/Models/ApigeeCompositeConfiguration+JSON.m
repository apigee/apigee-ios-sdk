//
//  ApigeeCompositeConfiguration+JSON.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeSystemLogger.h"
#import "NSDate+Apigee.h"
#import "ApigeeJSONConfigKeys.h"
#import "ApigeeMonitorSettings.h"
#import "ApigeeConfigFilter.h"
#import "ApigeeConfigFilter+JSON.h"
#import "ApigeeMonitorSettings+JSON.h"
#import "ApigeeCompositeConfiguration+JSON.h"


@implementation ApigeeCompositeConfiguration (JSON)

+ (ApigeeCompositeConfiguration *) fromDictionary:(NSDictionary *) jsonObjects
{
    if (!jsonObjects) {
        SystemError(@"JSON", @"There were no json objects");
        return nil;
    }
        
    ApigeeCompositeConfiguration *appConfig = [[ApigeeCompositeConfiguration alloc] init];

    appConfig.instaOpsApplicationId = [jsonObjects objectForKey:kAppConfigAppId];
    appConfig.orgName = [jsonObjects objectForKey:kAppConfigOrgName];
    appConfig.appName = [jsonObjects objectForKey:kAppConfigAppName];
    appConfig.fullAppName = [jsonObjects objectForKey:kAppConfigFullAppName];
    appConfig.appOwner = [jsonObjects objectForKey:kAppConfigAppOwner];
    
    if (![appConfig.createdDate isEqual:[NSNull null]]) {
        appConfig.createdDate = [NSDate dateFromMilliseconds:[[jsonObjects objectForKey:kAppConfigCreatedDate] unsignedLongLongValue]];
    }

    if (![appConfig.lastModifiedDate isEqual:[NSNull null]]) {
        appConfig.lastModifiedDate = [NSDate dateFromMilliseconds:[[jsonObjects objectForKey:kAppConfigLastModifiedDate] unsignedLongLongValue]];
    }

    appConfig.monitoringDisabled = [[jsonObjects objectForKey:kAppConfigMonitorDisabled] boolValue];
    appConfig.deleted = [[jsonObjects objectForKey:kAppConfigDeleted] boolValue];
    appConfig.googleId = [jsonObjects objectForKey:kAppConfigGoogleId];
    appConfig.appleId = [jsonObjects objectForKey:kAppConfigAppleId];
    appConfig.description = [jsonObjects objectForKey:kAppConfigDescription];
    appConfig.environment = [jsonObjects objectForKey:kAppConfigEnvironment];
    appConfig.customUploadUrl = [jsonObjects objectForKey:kAppConfigCustomUploadUrl];
    
    
    appConfig.deviceLevelOverrideEnabled = [[jsonObjects objectForKey:kAppConfigEnableDeviceLevelOverride] boolValue];
    appConfig.deviceTypeOverrideEnabled = [[jsonObjects objectForKey:kAppConfigEnableDeviceTypeOverride] boolValue];
    appConfig.ABTestingOverrideEnabled = [[jsonObjects objectForKey:kAppConfigEnableABTesting] boolValue];
    
    appConfig.deviceLevelSettings = [ApigeeMonitorSettings fromDictionary:[jsonObjects objectForKey:kAppConfigDeviceLevel]];
    appConfig.deviceTypeSettings = [ApigeeMonitorSettings fromDictionary:[jsonObjects objectForKey:kAppConfigDeviceType]];
    appConfig.abTestingSettings = [ApigeeMonitorSettings fromDictionary:[jsonObjects objectForKey:kAppConfigABTesting]];
    appConfig.defaultSettings = [ApigeeMonitorSettings fromDictionary:[jsonObjects objectForKey:kAppConfigDefault]];
    
    appConfig.abtestingPercentage = [jsonObjects objectForKey:kAppConfigABTestingPercentage];

    NSArray* array = nil;
    
    array = [jsonObjects objectForKey:kAppConfigDeviceNumberFilters];
    if( array ) {
        appConfig.deviceNumberFilters = [ApigeeConfigFilter transformArray:array];
    } else {
        appConfig.deviceNumberFilters = nil;
    }
    
    array = [jsonObjects objectForKey:kAppConfigDeviceIdFilters];
    if( array ) {
        appConfig.deviceIdFilters = [ApigeeConfigFilter transformArray:array];
    } else {
        appConfig.deviceIdFilters = nil;
    }
    
    array = [jsonObjects objectForKey:kAppConfigModelRegexFilters];
    if( array ) {
        appConfig.deviceModelRegexFilters = [ApigeeConfigFilter transformArray:array];
    } else {
        appConfig.deviceModelRegexFilters = nil;
    }
    
    array = [jsonObjects objectForKey:kAppConfigPlatformRegexFilters];
    if( array ) {
        appConfig.devicePlatformRegexFilters = [ApigeeConfigFilter transformArray:array];
    } else {
        appConfig.devicePlatformRegexFilters = nil;
    }
    
    array = [jsonObjects objectForKey:kAppConfigNetworkTypeRegexFilters];
    if( array ) {
        appConfig.networkTypeRegexFilters = [ApigeeConfigFilter transformArray:array];
    } else {
        appConfig.networkTypeRegexFilters = nil;
    }
    
    array = [jsonObjects objectForKey:kAppConfigNetworkOperatorRegexFilters];
    if( array ) {
        appConfig.networkOperatorRegexFilters = [ApigeeConfigFilter transformArray:array];
    } else {
        appConfig.networkOperatorRegexFilters = nil;
    }
    
    array = [jsonObjects objectForKey:kAppConfigOverrideFilters];
    if( array ) {
        appConfig.appConfigOverrideFilters = [ApigeeConfigFilter transformArray:array];
    } else {
        appConfig.appConfigOverrideFilters = nil;
    }

    
    return appConfig;
}

@end
