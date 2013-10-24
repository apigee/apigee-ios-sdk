//
//  ApigeeHTTPHelpers.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//
#import <Foundation/Foundation.h>

/*!
 @internal
 */
@interface NSString (ApigeeHTTPHelpers)
- (NSString *) URLEncodedString;
- (NSString *) URLDecodedString;
- (NSDictionary *) URLQueryDictionary;
@end

/*!
 @internal
 */
@interface NSData (ApigeeHTTPHelpers)
- (NSDictionary *) URLQueryDictionary;
@end

/*!
 @internal
 */
@interface NSDictionary (ApigeeHTTPHelpers)
- (NSString *) URLQueryString;
- (NSData *) URLQueryData;
@end
