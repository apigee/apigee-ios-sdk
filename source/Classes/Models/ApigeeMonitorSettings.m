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
