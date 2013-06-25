//
//  NSArray+InstaOpsConfigFilters.h
//  InstaOpsAppMonitor
//
//  Created by jaminschubert on 9/24/12.
//  Copyright (c) 2012 InstaOps. All rights reserved.
//

#import "ApigeeReachability.h"

@interface NSArray (ApigeeConfigFilters)

- (BOOL) isEmpty;
- (BOOL) containsPlatform:(NSString *) platform;
- (BOOL) containsNetworkSpeed:(ApigeeNetworkStatus) status;
- (BOOL) containsCarrier:(NSString *) carrier;
- (BOOL) containsDeviceModel:(NSString *) deviceModel;
- (BOOL) containsDeviceId:(NSString *) deviceId;

@end
