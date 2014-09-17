/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ApigeeSystemLogger.h"
#import "NSDate+Apigee.h"
#import "ApigeeJSONConfigKeys.h"
#import "ApigeeMonitoringSettings.h"
#import "ApigeeConfigFilter.h"
#import "ApigeeConfigFilter+JSON.h"
#import "ApigeeMonitoringSettings+JSON.h"
#import "ApigeeApp+JSON.h"


@implementation ApigeeApp (JSON)

+ (ApigeeApp *) fromDictionary:(NSDictionary *) jsonObjects
{
    if (!jsonObjects) {
        SystemError(@"JSON", @"There were no json objects");
        return nil;
    }
        
    ApigeeApp *appConfig = [[ApigeeApp alloc] init];

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
    
    appConfig.deviceLevelSettings = [ApigeeMonitoringSettings fromDictionary:[jsonObjects objectForKey:kAppConfigDeviceLevel]];
    appConfig.deviceTypeSettings = [ApigeeMonitoringSettings fromDictionary:[jsonObjects objectForKey:kAppConfigDeviceType]];
    appConfig.abTestingSettings = [ApigeeMonitoringSettings fromDictionary:[jsonObjects objectForKey:kAppConfigABTesting]];
    appConfig.defaultSettings = [ApigeeMonitoringSettings fromDictionary:[jsonObjects objectForKey:kAppConfigDefault]];
    
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
