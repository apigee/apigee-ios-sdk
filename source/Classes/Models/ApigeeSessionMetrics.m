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

#import "ApigeeModelUtils.h"
#import "ApigeeSessionMetrics.h"


@implementation ApigeeSessionMetrics

@synthesize appConfigType;
@synthesize appId;
@synthesize applicationVersion;
@synthesize batteryLevel;
@synthesize bearing;
@synthesize deviceCountry;
@synthesize deviceId;
@synthesize deviceModel;
@synthesize deviceOSVersion;
@synthesize devicePlatform;
@synthesize deviceType;
@synthesize endDay;
@synthesize endHour;
@synthesize endMinute;
@synthesize endMonth;
@synthesize endWeek;
@synthesize identifier;
@synthesize isNetworkChanged;
@synthesize isNetworkRoaming;
@synthesize latitude;
@synthesize localCountry;
@synthesize localLanguage;
@synthesize longitude;
@synthesize networkCarrier;
@synthesize networkCountry;
@synthesize networkExtraInfo;
@synthesize networkSubType;
@synthesize networkType;
@synthesize networkTypeName;
@synthesize sdkVersion;
@synthesize sdkType;
@synthesize sessionId;
@synthesize sessionStartTime;
@synthesize telephonyDeviceId;
@synthesize telephonyNetworkType;
@synthesize telephonyPhoneType;
@synthesize telephonySignalStrength;
@synthesize telephonyNetworkOperator;
@synthesize telephonyNetworkOperatorName;
@synthesize timeStamp;

- (NSDictionary*) asDictionary
{
    return [ApigeeModelUtils asDictionary:self];
}

@end
