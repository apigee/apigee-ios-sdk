//
//  ApigeeGroup.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApigeeEntity.h"

@class ApigeeDataClient;


/*!
 @class ApigeeGroup
 @abstract Class representing data associated with a group
 @see ApigeeEntity ApigeeEntity
 */
@interface ApigeeGroup : ApigeeEntity

@property (strong, nonatomic) NSString* path;
@property (strong, nonatomic) NSString* title;

/*!
 @abstract Compares the specified type name to the type name for ApigeeGroup
 @param type the type name to compare with
 @return boolean indicating whether the specified type name is the same as
 the type name for ApigeeGroup
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
