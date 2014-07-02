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

#import "ApigeeConfigFilter.h"
#import "NSArray+ApigeeConfigFilters.h"

#define kApigeeConfigFilterTypeDevicePlatform @"DEVICE_PLATFORM"
#define kApigeeConfigFilterTypeDeviceModel @"DEVICE_MODEL"
#define kApigeeConfigFilterTypeDeviceId @"DEVICE_ID"
#define kApigeeConfigFilterTypeNetworkType @"NETWORK_TYPE"
#define kApigeeConfigFilterTypeCarrier @"NETWORK_OPERATOR"

#define kWifiNetworkType @"wifi"

@implementation NSArray (ApigeeConfigFilters)

- (BOOL) isEmpty
{
    return ([self count] == 0);
}

- (BOOL) containsPlatform:(NSString *) platform
{
    return [self applyFilter:kApigeeConfigFilterTypeDevicePlatform on:platform];
}

- (BOOL) containsNetworkSpeed:(ApigeeNetworkStatus) status
{
    if ([self count] == 0) {
        return YES;
    }
    
    if (status == Apigee_ReachableViaWiFi) {
        return [self containsWifiNetworkStatus];
    } else if (status == Apigee_ReachableViaWWAN){
        return [self containsWWANNetworkStatus];
    } else {
        return NO;
    }
}

- (BOOL) containsCarrier:(NSString *) carrier
{
    return [self applyFilter:kApigeeConfigFilterTypeCarrier on:carrier];
}

- (BOOL) containsDeviceModel:(NSString *) deviceModel
{
    return [self applyFilter:kApigeeConfigFilterTypeDeviceModel on:deviceModel];
}

- (BOOL) containsDeviceId:(NSString *) deviceId
{
    return [self applyFilter:kApigeeConfigFilterTypeDeviceId on:deviceId];
}

#pragma mark - Internal implementation

- (BOOL) applyFilter:(NSString *) type on:(NSString *) value
{
    //empty ==> the filter class is ignored
    if ([self count] == 0) {
        return YES;
    }
    
    for (ApigeeConfigFilter *filter in self) {
        if (![filter.filterType isEqualToString:type]) {
            continue;
        }
        
        if ([filter.filterValue isEqualToString:value]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) containsWifiNetworkStatus
{
    for (ApigeeConfigFilter *filter in self) {
        if (![filter.filterType isEqualToString:kApigeeConfigFilterTypeNetworkType]) {
            continue;
        }
        
        //normalize value 
        NSString *value = [filter.filterValue lowercaseString];
        
        if ([value isEqualToString:kWifiNetworkType]) {
            return YES;
        }
    }
    
    return NO;
}


/**
 * Todo: Fix if network status can be determined.
 * Currently, we haven't figured out how to get the network type in a sanctioned manner
 * from iOS. As such, we assume if there is more than one that in the filter list other than wifi,
 * then WWAN was specified.
 */
- (BOOL) containsWWANNetworkStatus
{
    if ([self containsWifiNetworkStatus]) {
        return ([self count] > 2);
    } else {
        return ([self count] > 1);
    }
}

@end
