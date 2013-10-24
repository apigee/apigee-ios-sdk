//
//  ApigeeDevice.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApigeeEntity.h"

/*!
 @class ApigeeDevice
 @abstract Class representing data associated with a device
 @see ApigeeEntity ApigeeEntity
 */
@interface ApigeeDevice : ApigeeEntity

@property (strong, nonatomic) NSString* name;

/*!
 @abstract Compares the specified type name to the type name for ApigeeDevice
 @param type the type name to compare with
 @return boolean indicating whether the specified type name is the same as
 the type name for ApigeeDevice
 */
+ (BOOL)isSameType:(NSString*)type;

/*!
 @abstract
 @param dataClient
 */
- (id)initWithDataClient:(ApigeeDataClient *)dataClient;

/*!
 @abstract
 @param entity
 */
- (id)initWithEntity:(ApigeeEntity*)entity;

@end
