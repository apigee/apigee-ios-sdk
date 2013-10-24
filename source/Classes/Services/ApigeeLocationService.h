//
//  ApigeeLocationService.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

/*!
 @internal
 */
@interface ApigeeLocationPolicy : NSObject

@property (assign, nonatomic) float minAccuracyThreshold;
@property (assign, nonatomic) float maxAccuracyThreshold;
@property (assign, nonatomic) NSTimeInterval scanDuration;

@end

/*!
 @internal
 */
@protocol ApigeeLocationServiceDelegate <NSObject>

- (void) complete:(BOOL) success;

@end

/*!
 @internal
 */
@interface ApigeeLocationService : NSObject<CLLocationManagerDelegate>

@property (weak, nonatomic) id<ApigeeLocationServiceDelegate> delegate;
@property (readonly, nonatomic) CLLocation *location;
@property (readonly, nonatomic) BOOL working;


+ (ApigeeLocationService *) defaultService;

- (id) initWith:(ApigeeLocationPolicy *) policy;
- (id) initWithDefaultPolicy;
- (id) initWithDefaultPolicyFor:(id<ApigeeLocationServiceDelegate>) delegate;

- (void) reset;
- (void) startScan;

@end
