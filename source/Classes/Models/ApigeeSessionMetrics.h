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

@interface ApigeeSessionMetrics : NSObject

    @property (strong, nonatomic) NSString *appConfigType;
    @property (strong, nonatomic) NSString *appId;
    @property (strong, nonatomic) NSString *applicationVersion;
    @property (strong, nonatomic) NSString *batteryLevel;
    @property (strong, nonatomic) NSString *bearing;
    @property (strong, nonatomic) NSString *deviceCountry;
    @property (strong, nonatomic) NSString *deviceId;
    @property (strong, nonatomic) NSString *deviceModel;
    @property (strong, nonatomic) NSString *deviceOSVersion;
    @property (strong, nonatomic) NSString *devicePlatform;
    @property (strong, nonatomic) NSString *deviceType;
    @property (strong, nonatomic) NSString *endDay;
    @property (strong, nonatomic) NSString *endHour;
    @property (strong, nonatomic) NSString *endMinute;
    @property (strong, nonatomic) NSString *endMonth;
    @property (strong, nonatomic) NSString *endWeek;
    @property (strong, nonatomic) NSString *identifier;
    @property (strong, nonatomic) NSString *isNetworkChanged;
    @property (strong, nonatomic) NSString *isNetworkRoaming;
    @property (strong, nonatomic) NSString *latitude;
    @property (strong, nonatomic) NSString *localCountry;
    @property (strong, nonatomic) NSString *localLanguage;
    @property (strong, nonatomic) NSString *longitude;
    @property (strong, nonatomic) NSString *networkCarrier;
    @property (strong, nonatomic) NSString *networkCountry;
    @property (strong, nonatomic) NSString *networkExtraInfo;
    @property (strong, nonatomic) NSString *networkSubType;
    @property (strong, nonatomic) NSString *networkType;
    @property (strong, nonatomic) NSString *networkTypeName;
    @property (strong, nonatomic) NSString *sdkVersion;
    @property (strong, nonatomic) NSString *sdkType;
    @property (strong, nonatomic) NSString *sessionId;
    @property (strong, nonatomic) NSString *sessionStartTime;
    @property (strong, nonatomic) NSString *telephonyDeviceId;
    @property (strong, nonatomic) NSString *telephonyNetworkType;
    @property (strong, nonatomic) NSString *telephonyPhoneType;
    @property (strong, nonatomic) NSString *telephonySignalStrength;
    @property (strong, nonatomic) NSString *telephonyNetworkOperator;
    @property (strong, nonatomic) NSString *telephonyNetworkOperatorName;
    @property (strong, nonatomic) NSString *timeStamp;

- (NSDictionary*) asDictionary;

@end
