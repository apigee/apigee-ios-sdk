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

#import "ApigeeCompositeConfiguration.h"

@implementation ApigeeCompositeConfiguration

@synthesize instaOpsApplicationId;
@synthesize applicationUUID;
@synthesize organizationUUID;
@synthesize orgName;
@synthesize appName;
@synthesize fullAppName;
@synthesize appOwner;

@synthesize googleId;
@synthesize appleId;
@synthesize description;
@synthesize environment;
@synthesize customUploadUrl;

@synthesize createdDate;
@synthesize lastModifiedDate;

@synthesize monitoringDisabled;
@synthesize deleted;
@synthesize deviceLevelOverrideEnabled;
@synthesize deviceTypeOverrideEnabled;
@synthesize ABTestingOverrideEnabled;

@synthesize defaultSettings;
@synthesize deviceTypeSettings;
@synthesize deviceLevelSettings;
@synthesize abTestingSettings;

@synthesize abtestingPercentage;

@synthesize appConfigOverrideFilters;
@synthesize deviceNumberFilters;
@synthesize deviceIdFilters;
@synthesize deviceModelRegexFilters;
@synthesize devicePlatformRegexFilters;
@synthesize networkTypeRegexFilters;
@synthesize networkOperatorRegexFilters;


- (id) init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.defaultSettings = [[ApigeeMonitorSettings alloc] init];
    self.deviceLevelSettings = [[ApigeeMonitorSettings alloc] init];
    self.deviceTypeSettings = [[ApigeeMonitorSettings alloc] init];
    self.abTestingSettings = [[ApigeeMonitorSettings alloc] init];
    
    self.appConfigOverrideFilters = [NSArray array];
    self.deviceNumberFilters = [NSArray array];
    self.deviceIdFilters = [NSArray array];
    self.deviceModelRegexFilters = [NSArray array];
    self.devicePlatformRegexFilters = [NSArray array];
    self.networkTypeRegexFilters = [NSArray array];
    self.networkOperatorRegexFilters = [NSArray array];

    return self;
}
@end
