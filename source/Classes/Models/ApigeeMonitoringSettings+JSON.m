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

#import "ApigeeJSONConfigKeys.h"
#import "NSDate+Apigee.h"
#import "ApigeeCustomConfigParam.h"
#import "ApigeeNetworkConfig.h"
#import "ApigeeCustomConfigParam+JSON.h"
#import "ApigeeNetworkConfig+JSON.h"
#import "ApigeeMonitoringSettings+JSON.h"

@implementation ApigeeMonitoringSettings (JSON)

+ (ApigeeMonitoringSettings *) fromDictionary:(NSDictionary *) jsonObjects
{
    ApigeeMonitoringSettings *settings = [[ApigeeMonitoringSettings alloc] init];    
    
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
