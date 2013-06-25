//
//  CompositeApplicationConfigurationModel.m
//  ApigeeAppMonitoring
//
//  Created by Sam Griffith on 5/8/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

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
