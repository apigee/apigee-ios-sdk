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

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "NSString+UUID.h"
#import "NSDate+Apigee.h"
#import "OpenUDID.h"
#import "ApigeeReachability.h"
#import "ApigeeLocationService.h"
#import "ApigeeSessionMetricsCompiler.h"
#import "UIDevice+Apigee.h"
#import "ApigeeMonitoringClient.h"

#define kValueUnkown @"UNKNOWN"
#define kApigeeSessionIdKey @"kApigeeSessionIdKey"
#define kApigeeSessionTimeStampKey @"kApigeeSessionTimeStampKey"

#define kApigeeDefaultSessionTimeout (30.0f * 60.0f) // 30 min time out

@interface ApigeeSessionMetricsCompiler ()

@property (assign, nonatomic) BOOL networkChanged;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSDate *sessionStart;

- (void) networkChanged:(NSNotification *) notice;
- (void) createSession:(NSNotification *) notice;

@end

@implementation ApigeeSessionMetricsCompiler

@synthesize sessionId;

#pragma mark - Instance management

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (ApigeeSessionMetricsCompiler *) systemCompiler
{
    static ApigeeSessionMetricsCompiler *instance;
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[ApigeeSessionMetricsCompiler alloc] init];

        instance.networkChanged = NO;
        [instance createSession:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:instance selector: @selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(createSession:) name:UIApplicationWillEnterForegroundNotification object:nil];
    });
    
    return instance;
}

#pragma mark - Public implementation

- (ApigeeSessionMetrics *) compileMetricsForSettings:(ApigeeActiveSettings *) settings
                                              isWiFi:(BOOL)isWiFi
{
    ApigeeSessionMetrics *metrics = [[ApigeeSessionMetrics alloc] init];
    UIDevice *currentDevice = [UIDevice currentDevice];
        
    metrics.appConfigType = settings.activeConfigurationName;
    metrics.appId = [settings.instaOpsApplicationId stringValue];
    metrics.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    metrics.timeStamp = [NSDate stringFromMilliseconds:[NSDate nowAsMilliseconds]];
    metrics.sdkVersion = [ApigeeMonitoringClient sdkVersion];
    metrics.sdkType = @"iOS";
    
    if (settings.batteryStatusCaptureEnabled) {
        metrics.batteryLevel = [[NSNumber numberWithFloat: (100 * [currentDevice batteryLevel])] stringValue];
    } else {
        metrics.batteryLevel = nil;
    }

    NSLocale *locale = [NSLocale currentLocale];
    
    BOOL isCapturingCarrierInfo = NO;

    if (!isWiFi) {
        
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [networkInfo subscriberCellularProvider];

        if( carrier && ([carrier.carrierName length] > 0) )
        {
            //NSString *mcc = [carrier mobileCountryCode];
            if( settings.networkCarrierCaptureEnabled && !isWiFi )
            {
                isCapturingCarrierInfo = YES;
                metrics.networkCarrier = carrier.carrierName;
                metrics.networkCountry = carrier.isoCountryCode;
            }

            // Until we figure out what we want to do here...
            //metrics.deviceCountry = [locale displayNameForKey:NSLocaleCountryCode value:mcc];
            metrics.deviceCountry = kValueUnkown;
        }
    }
    
    if (!isCapturingCarrierInfo)
    {
        metrics.networkCarrier = kValueUnkown;
        metrics.networkCountry = kValueUnkown;
        metrics.deviceCountry = kValueUnkown;
    }

    metrics.networkType = isWiFi ? @"WIFI" : @"MOBILE";
    metrics.networkSubType = kValueUnkown;
    
    if (settings.locationCaptureEnabled) {
#if !(TARGET_IPHONE_SIMULATOR)
        CLLocation *location = [ApigeeLocationService defaultService].location;
        if (location) {
            metrics.latitude = [NSString stringWithFormat:@"%f",  location.coordinate.latitude];
            metrics.longitude = [NSString stringWithFormat:@"%f",  location.coordinate.longitude];
            metrics.bearing = [NSString stringWithFormat:@"%f",  location.course];
        } else {
            metrics.latitude = @"0.0";
            metrics.longitude = @"0.0";
            metrics.bearing = @"0.0";
        }
#else
        metrics.latitude = @"0.0";
        metrics.longitude = @"0.0";
        metrics.bearing = @"0.0";
#endif
    }
    
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSString *countryName = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];

    metrics.localCountry = countryName;
    metrics.localLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    metrics.deviceOSVersion = [currentDevice systemVersion];
    metrics.devicePlatform = [currentDevice systemName];
    
    if (settings.deviceModelCaptureEnabled) {
        // the 'model' property on UIDevice only gives values such as
        // 'iPhone', 'iPod', 'iPad' (very generic)
        //metrics.deviceModel = [currentDevice model];
        
        // we want more details to know the specifics
        metrics.deviceModel = [UIDevice platformStringDescriptive];
    } else {
        metrics.deviceModel = kValueUnkown;
    }

    if (settings.deviceIdCaptureEnabled) {
        metrics.deviceId = [OpenUDID value];
    } else {
        metrics.deviceId = kValueUnkown;
    }
    
    metrics.sessionStartTime = [NSDate stringFromMilliseconds:[self.sessionStart dateAsMilliseconds]];
    metrics.sessionId = self.sessionId;
    
    if (self.networkChanged) {
        metrics.isNetworkChanged = @"true";
    } else {
        metrics.isNetworkChanged = @"false";
    }
    
    return metrics;
}

#pragma mark - Reachability notification handler

- (void) networkChanged:(NSNotification *) notice
{
    self.networkChanged = YES;
}

#pragma mark - Session lifecycle handler

- (void) createSession:(NSNotification *) notice
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.sessionId = [standardUserDefaults objectForKey:kApigeeSessionIdKey];
    self.sessionStart = [standardUserDefaults objectForKey:kApigeeSessionTimeStampKey];
    
    if ((!self.sessionStart) || ([[NSDate date] timeIntervalSinceDate:self.sessionStart] > kApigeeDefaultSessionTimeout)) {
        self.sessionId = [NSString uuid];
        self.sessionStart = [NSDate date];
        
        [standardUserDefaults setObject:self.sessionId forKey:kApigeeSessionIdKey];
        [standardUserDefaults setObject:self.sessionStart forKey:kApigeeSessionTimeStampKey];
    }
}

@end
