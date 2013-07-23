//
//  ApigeeActiveSettings.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "NSArray+ApigeeConfigFilters.h"
#import "ApigeeOpenUDID.h"
#import "ApigeeNetworkConfig.h"
#import "ApigeeMonitorSettings.h"
#import "ApigeeActiveSettings.h"

#define kApigeeActiveConfigNameDeviceLevel @"DEVICE_LEVEL"
#define kApigeeActiveConfigNameDeviceType @"DEVICE_TYPE"
#define kApigeeActiveConfigNameABTesting @"AB_TYPE"
#define kApigeeActiveConfigNameDefault @"DEFAULT"

@interface ApigeeActiveSettings ()

@property (strong, nonatomic) ApigeeCompositeConfiguration *config;

- (ApigeeMonitorSettings *) activeSettings;

@end

@implementation ApigeeActiveSettings

@synthesize config;
@synthesize activeNetworkStatus;

#pragma mark - Memory management

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id) initWithConfig:(ApigeeCompositeConfiguration *) compositeConfig
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.config = compositeConfig;
    return self;
}

#pragma mark - Internal implementation

- (ApigeeMonitorSettings *) activeSettings
{
    ApigeeActiveConfiguraiton active = [self activeConfiguration];
    
    if (active == kApigeeDeviceLevel) {
        return self.config.deviceLevelSettings;
    }
    
    if (active == kApigeeDeviceType) {
        return self.config.deviceTypeSettings;
    }
    
    if (active == kApigeeABTesting) {
        return self.config.abTestingSettings;
    }
    
    return self.config.defaultSettings;
}

#pragma mark - App level settings

- (NSNumber *) instaOpsApplicationId
{
    return self.config.instaOpsApplicationId;
}

- (NSString *)applicationUUID
{
    return self.config.applicationUUID;
}

- (NSString *)organizationUUID
{
    return self.config.organizationUUID;
}

- (NSString *) orgName
{
    return self.config.orgName;
}

- (NSString *) appName
{
    return self.config.appName;
}

- (NSString *) fullAppName
{
    return self.config.fullAppName;
}

- (NSString *) appOwner
{
    return self.config.appOwner;
}

- (NSDate *) appCreatedDate
{
    return self.config.createdDate;
}

- (NSDate *) appLastModifiedDate
{
    return self.config.lastModifiedDate;
}

- (BOOL) monitoringDisabled
{
    return self.config.monitoringDisabled;
}

- (BOOL) deleted
{
    return self.config.deleted;
}

- (NSString *) googleId
{
    return self.config.googleId;
}

- (NSString *) appleId
{
    return self.config.appleId;
}

- (NSString *) appDescription
{
    return self.config.description;
}

- (NSString *) environment
{
    return self.config.environment;
}

- (NSString *) customUploadUrl
{
    return self.config.customUploadUrl;
}

- (NSNumber *) abtestingPercentage
{
    return self.config.abtestingPercentage;
}

- (NSArray *) appConfigOverrideFilters
{
    return self.config.appConfigOverrideFilters;
}

- (NSArray *) deviceNumberFilters
{
    return self.config.deviceNumberFilters;
}

- (NSArray *) deviceIdFilters
{
    return self.config.deviceIdFilters;
}

- (NSArray *) devicePlatformRegexFilters
{
    return self.config.devicePlatformRegexFilters;
}

- (NSArray *) networkTypeRegexFilters
{
    return self.config.networkTypeRegexFilters;
}

- (NSArray *) networkOperatorRegexFilters
{
    return self.config.networkOperatorRegexFilters;
}


- (ApigeeActiveConfiguraiton) activeConfiguration
{
    if (self.config.deviceLevelOverrideEnabled) {
        if ([self.deviceIdFilters containsDeviceId:[ApigeeOpenUDID value]]) {
            return kApigeeDeviceLevel;
        }
    }
    
    BOOL empty = [self.config.devicePlatformRegexFilters isEmpty] &&
    [self.config.networkTypeRegexFilters isEmpty] &&
    [self.config.networkOperatorRegexFilters isEmpty] &&
    [self.config.deviceModelRegexFilters isEmpty];
    
    if (self.config.deviceTypeOverrideEnabled && !empty) {
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [networkInfo subscriberCellularProvider];
                    
        if ([self.config.devicePlatformRegexFilters containsPlatform:[[UIDevice currentDevice] systemName]] &&
            [self.config.deviceModelRegexFilters containsDeviceModel:[[UIDevice currentDevice] model]] &&
            [self.config.networkTypeRegexFilters containsNetworkSpeed:self.activeNetworkStatus] &&
            [self.config.networkOperatorRegexFilters containsCarrier:carrier.carrierName]) {
                             
            return kApigeeDeviceType;
        }
    }
    
    if (self.config.ABTestingOverrideEnabled) {
        
        //coin flip for ab testing config application
        uint32_t r = arc4random() % 100;
        
        if (r < [self.abtestingPercentage intValue]) {
            return kApigeeABTesting;
        }
    }
    
    return kApigeeDefault;
}

- (NSString *) activeConfigurationName
{
    ApigeeActiveConfiguraiton active = [self activeConfiguration];
    
    if (active == kApigeeDeviceLevel) {
        return kApigeeActiveConfigNameDeviceLevel;
    }
    
    if (active == kApigeeDeviceType) {
        return kApigeeActiveConfigNameDeviceType;
    }
    
    if (active == kApigeeABTesting) {
        return kApigeeActiveConfigNameABTesting;
    }
    
    return kApigeeActiveConfigNameDefault;
}

#pragma mark - Overridable settings

- (NSString *) settingsDescription
{
    return self.activeSettings.description;
}

- (NSDate *) settingsLastModifiedDate
{
    return self.activeSettings.lastModifiedDate;
}

- (NSArray *) urlRegex
{
    return self.activeSettings.urlRegex;
}

- (BOOL) networkMonitoringEnabled
{
    return self.activeSettings.networkMonitoringEnabled;
}

- (NSInteger ) logLevelToMonitor
{
    return self.activeSettings.logLevelToMonitor;
}

- (BOOL) enableLogMonitoring
{
    return self.activeSettings.enableLogMonitoring;
}

- (NSArray *) customConfigParams
{
    return self.activeSettings.customConfigParams;
}

- (NSArray *) deletedCustomConfigParams
{
    return self.activeSettings.deletedCustomConfigParams;
}

- (ApigeeNetworkConfig *) networkConfig
{
    return self.activeSettings.networkConfig;
}

- (BOOL) cachingEnabled
{
    return self.activeSettings.cachingEnabled;
}

- (BOOL) monitorAllUrls
{
    return self.activeSettings.monitorAllUrls;
}

- (BOOL) sessionDataCaptureEnabled
{
    return self.activeSettings.sessionDataCaptureEnabled;
}

- (BOOL) batteryStatusCaptureEnabled
{
    return self.activeSettings.batteryStatusCaptureEnabled;
}

- (BOOL) imeicaptureEnabled
{
    return self.activeSettings.imeicaptureEnabled;
}

- (BOOL) obfuscateIMEI
{
    return self.activeSettings.obfuscateIMEI;
}

- (BOOL) deviceIdCaptureEnabled
{
    return self.activeSettings.deviceIdCaptureEnabled;
}

- (BOOL) obfuscateDeviceId
{
    return self.activeSettings.obfuscateDeviceId;
}

- (BOOL) deviceModelCaptureEnabled
{
    return self.activeSettings.deviceModelCaptureEnabled;
}

- (BOOL) locationCaptureEnabled
{
    return self.activeSettings.locationCaptureEnabled;
}

- (NSInteger) locationCaptureResolution
{
    return self.activeSettings.locationCaptureResolution;
}

- (BOOL) networkCarrierCaptureEnabled
{
    return self.activeSettings.networkCarrierCaptureEnabled;
}

- (BOOL) enableUploadWhenRoaming
{
    return self.activeSettings.enableUploadWhenRoaming;
}

- (BOOL) enableUploadWhenMobile
{
    return self.activeSettings.enableUploadWhenMobile;
}

- (NSInteger) agentUploadInterval
{
    return self.activeSettings.agentUploadInterval;
}

- (NSInteger) agentUploadIntervalInSeconds
{
    return self.activeSettings.agentUploadIntervalInSeconds;
}

- (NSInteger) samplingRate
{
    return self.activeSettings.samplingRate;
}

@end
