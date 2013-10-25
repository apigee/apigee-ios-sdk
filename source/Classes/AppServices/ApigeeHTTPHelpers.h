//
//  ApigeeHTTPHelpers.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString (ApigeeHTTPHelpers)
- (NSString *) URLEncodedString;
- (NSString *) URLDecodedString;
- (NSDictionary *) URLQueryDictionary;
@end

@interface NSData (ApigeeHTTPHelpers)
- (NSDictionary *) URLQueryDictionary;
@end

@interface NSDictionary (ApigeeHTTPHelpers)
- (NSString *) URLQueryString;
- (NSData *) URLQueryData;
@end
