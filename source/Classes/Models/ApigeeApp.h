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


#import "ApigeeMonitoringSettings.h"


@interface ApigeeApp : NSObject

@property (strong, nonatomic) NSNumber *instaOpsApplicationId;
@property (strong, nonatomic) NSString *applicationUUID;
@property (strong, nonatomic) NSString *organizationUUID;
@property (strong, nonatomic) NSString *orgName;
@property (strong, nonatomic) NSString *appName;
@property (strong, nonatomic) NSString *fullAppName;
@property (strong, nonatomic) NSString *appOwner;

@property (strong, nonatomic) NSString *googleId;
@property (strong, nonatomic) NSString *appleId;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *environment;
@property (strong, nonatomic) NSString *customUploadUrl;

@property (strong, nonatomic) NSDate *createdDate;
@property (strong, nonatomic) NSDate *lastModifiedDate;

@property (assign, nonatomic) BOOL monitoringDisabled;
@property (assign, nonatomic) BOOL deleted;
@property (assign, nonatomic) BOOL deviceLevelOverrideEnabled;
@property (assign, nonatomic) BOOL deviceTypeOverrideEnabled;
@property (assign, nonatomic) BOOL ABTestingOverrideEnabled;

@property (strong, nonatomic) ApigeeMonitoringSettings *defaultSettings;
@property (strong, nonatomic) ApigeeMonitoringSettings *deviceLevelSettings;
@property (strong, nonatomic) ApigeeMonitoringSettings *deviceTypeSettings;
@property (strong, nonatomic) ApigeeMonitoringSettings *abTestingSettings;

@property (strong, nonatomic) NSNumber *abtestingPercentage;

@property (strong, nonatomic) NSArray *appConfigOverrideFilters;
@property (strong, nonatomic) NSArray *deviceNumberFilters;
@property (strong, nonatomic) NSArray *deviceIdFilters;
@property (strong, nonatomic) NSArray *deviceModelRegexFilters;
@property (strong, nonatomic) NSArray *devicePlatformRegexFilters;
@property (strong, nonatomic) NSArray *networkTypeRegexFilters;
@property (strong, nonatomic) NSArray *networkOperatorRegexFilters;


@end
