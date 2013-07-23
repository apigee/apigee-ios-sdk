//
//  ApigeeHTTPResult.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface ApigeeHTTPResult : NSObject
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id object;
@property (nonatomic, readonly) NSString *UTF8String;

@end
