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

@import CoreLocation;

@interface ApigeeLocationPolicy : NSObject

@property (assign, nonatomic) float minAccuracyThreshold;
@property (assign, nonatomic) float maxAccuracyThreshold;
@property (assign, nonatomic) NSTimeInterval scanDuration;

@end


@protocol ApigeeLocationServiceDelegate <NSObject>

- (void) complete:(BOOL) success;

@end


@interface ApigeeLocationService : NSObject<CLLocationManagerDelegate>

@property (weak, nonatomic) id<ApigeeLocationServiceDelegate> delegate;
@property (readonly, nonatomic) CLLocation *location;
@property (readonly, nonatomic) BOOL working;


+ (ApigeeLocationService *) defaultService;

- (id) initWith:(ApigeeLocationPolicy *) policy;
- (id) initWithDefaultPolicy;
- (id) initWithDefaultPolicyFor:(id<ApigeeLocationServiceDelegate>) delegate;

- (void) stopScan;
- (void) startScan;

@end
