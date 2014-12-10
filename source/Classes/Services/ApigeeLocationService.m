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

#import "ApigeeLocationService.h"
#import "ApigeeSystemLogger.h"

#define kMinAccuracyThreshold 5.0f    //meters
#define kMaxAccuracyThreshold 100.0f  //meters
#define kScanDuration 45.0f           //seconds

@interface ApigeeLocationPolicy ()

- (BOOL) targetReached:(CLLocation *) location;
- (BOOL) canAccept:(CLLocation *) location;
- (BOOL) canContinue:(NSTimeInterval) duration;

@end

@implementation ApigeeLocationPolicy

- (BOOL) targetReached:(CLLocation *)location
{
    return (location.horizontalAccuracy <= self.minAccuracyThreshold);
}

- (BOOL) canAccept:(CLLocation *) location
{
    return (location.horizontalAccuracy <= self.maxAccuracyThreshold);
}

- (BOOL) canContinue:(NSTimeInterval)duration
{
    return (duration < self.scanDuration);
}

@end

@interface ApigeeLocationService ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) ApigeeLocationPolicy *policy;
@property (strong, nonatomic) NSDate *scanStart;

@end

@implementation ApigeeLocationService

#pragma mark - Initializattion and clean up

- (void) dealloc
{
    self.delegate = nil;
    [self.locationManager stopUpdatingLocation];
}

+ (ApigeeLocationService *) defaultService
{
    static ApigeeLocationService *instance;
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[ApigeeLocationService alloc] initWithDefaultPolicy];
    });
    
    return instance;
}

- (id) initWithDefaultPolicyFor:(id<ApigeeLocationServiceDelegate>)delegate
{
    self = [self initWithDefaultPolicy];
    self.delegate = delegate;
    
    return self;
}

- (id) initWithDefaultPolicy
{
    ApigeeLocationPolicy *defaultPolicy = [[ApigeeLocationPolicy alloc] init];
    defaultPolicy.minAccuracyThreshold = kMinAccuracyThreshold;
    defaultPolicy.maxAccuracyThreshold = kMaxAccuracyThreshold;
    defaultPolicy.scanDuration = kScanDuration;
    
    return [self initWith:defaultPolicy];
}

/* Designated initializer */
- (id) initWith:(ApigeeLocationPolicy*) policy
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.policy = policy;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    _location = nil;
    _working = NO;
    
    return self;
}

#pragma mark - Implementation

- (void) stopScan
{
    @synchronized(self) {
        _location = nil;
        
        if (!self.working) {
            return;
        }
        
        _working = NO;
        [self.locationManager stopUpdatingLocation];
    }
}

- (void) startScan
{
    @synchronized(self) {
        if (self.working) {
            return;
        }
        
        _working = YES;
        _location = nil;
        
        self.scanStart = [[NSDate alloc] init];
        
        if ([CLLocationManager locationServicesEnabled]) {
            [self.locationManager startUpdatingLocation];
        } else {
            _working = NO;
            [self.delegate complete:NO];
        }
    }
}

#pragma mark - Core Location Delegate

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    @synchronized (self) {
        //check to see if we were stopped
        if (!self.working) {
            return;
        }
        
        NSTimeInterval interval = [newLocation.timestamp timeIntervalSinceDate:self.scanStart];
        
        //filter out any cached locations
        if (interval < 0) {
            return;
        }
        
        BOOL updateLocation = NO;
        if ([self.policy targetReached:newLocation]) {
            updateLocation = YES;
            _working = NO;
        } else if ([self.policy canContinue:interval] && [self.policy canAccept:newLocation]) {
            updateLocation = YES;
        } else if (![self.policy canContinue:interval]){
            _working = NO;
        }
        
        //only accept update if accuracy improved
        if (updateLocation) {
            if (self.location == nil)
                _location = newLocation;
            else if (newLocation.horizontalAccuracy <= self.location.horizontalAccuracy)
                _location = newLocation;
        }
        
        if (self.working) {
            return;
        }
        
        [manager stopUpdatingLocation];
        
        if ([self.policy canAccept:self.location]) {
            [self.delegate complete:YES];
        } else {
            [self.delegate complete:NO];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    _working = NO;
    NSString *logMessage;
    
    switch([error code])
    {
        case kCLErrorLocationUnknown:
            logMessage = @"Location is unknown";
            break;
        case kCLErrorNetwork: // general, network-related error
            logMessage = @"Network not available or device in Airplane mode";
            break;
        case kCLErrorDenied:
            logMessage = @"User denied access to location capture";
            break;
        default:
            logMessage = @"Error occurred in obtaining location";
            break;
    }
    
    ApigeeLogInfoMessage(@"MOBILE_AGENT",logMessage);

    if ([self.policy canAccept:self.location]) {
        [self.delegate complete:YES];
    } else {
        [self.delegate complete:NO];
    }
}

@end
