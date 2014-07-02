/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
