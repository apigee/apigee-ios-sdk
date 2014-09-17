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

@class ApigeeNetworkConfig;

@interface ApigeeMonitoringSettings : NSObject

@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSDate *lastModifiedDate;
@property (strong, nonatomic) NSArray *urlRegex;
@property (assign, nonatomic) BOOL networkMonitoringEnabled;
@property (assign, nonatomic) NSInteger logLevelToMonitor;
@property (assign, nonatomic) BOOL enableLogMonitoring;
@property (strong, nonatomic) NSArray *customConfigParams;
@property (strong, nonatomic) NSArray *deletedCustomConfigParams;
@property (strong, nonatomic) NSString *appConfigType;
@property (strong, nonatomic) ApigeeNetworkConfig *networkConfig;
@property (assign, nonatomic) BOOL cachingEnabled;
@property (assign, nonatomic) BOOL monitorAllUrls;
@property (assign, nonatomic) BOOL sessionDataCaptureEnabled;
@property (assign, nonatomic) BOOL batteryStatusCaptureEnabled;
@property (assign, nonatomic) BOOL imeicaptureEnabled;
@property (assign, nonatomic) BOOL obfuscateIMEI;
@property (assign, nonatomic) BOOL deviceIdCaptureEnabled;
@property (assign, nonatomic) BOOL obfuscateDeviceId;
@property (assign, nonatomic) BOOL deviceModelCaptureEnabled;
@property (assign, nonatomic) BOOL locationCaptureEnabled;
@property (assign, nonatomic) NSInteger locationCaptureResolution;
@property (assign, nonatomic) BOOL networkCarrierCaptureEnabled;
@property (assign, nonatomic) NSInteger appConfigId;
@property (assign, nonatomic) BOOL enableUploadWhenRoaming;
@property (assign, nonatomic) BOOL enableUploadWhenMobile;
@property (assign, nonatomic) NSInteger agentUploadInterval;
@property (assign, nonatomic) NSInteger agentUploadIntervalInSeconds;
@property (assign, nonatomic) NSInteger samplingRate;

@end
