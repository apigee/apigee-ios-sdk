//
//  ApigeeMessage.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApigeeEntity.h"

@class ApigeeDataClient;

/*!
 @class ApigeeMessage
 @abstract Class representing data associated with a message
 @see ApigeeEntity ApigeeEntity
 */
@interface ApigeeMessage : ApigeeEntity

@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSString* correlationId;
@property (strong, nonatomic) NSString* destination;
@property (strong, nonatomic) NSString* replyTo;
@property (assign, nonatomic) BOOL persistent;
@property (assign, nonatomic) BOOL indexed;

/*!
 @abstract Compares the specified type name to the type name for ApigeeMessage
 @param type the type name to compare with
 @return boolean indicating whether the specified type name is the same as
 the type name for ApigeeMessage
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
