//
//  ApigeeHTTPResult.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//
#import <Foundation/Foundation.h>

/*!
 @class ApigeeHTTPResult
 @abstract
 */
@interface ApigeeHTTPResult : NSObject

/*!
 @property response
 @abstract
 @discussion
 */
@property (nonatomic, strong) NSHTTPURLResponse *response;

/*!
 @property data
 @abstract
 @discussion
 */
@property (nonatomic, strong) NSData *data;

/*!
 @property error
 @abstract
 @discussion
 */
@property (nonatomic, strong) NSError *error;

/*!
 @property object
 @abstract
 @discussion
 */
@property (nonatomic, strong) id object;

/*!
 @property UTF8String
 @abstract
 @discussion
 */
@property (nonatomic, readonly) NSString *UTF8String;

@end
