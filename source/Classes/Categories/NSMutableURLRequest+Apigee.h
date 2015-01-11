//
//  NSMutableURLRequest+Apigee.h
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 10/21/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

@interface NSMutableURLRequest (Apigee)

+ (void)basicAuthForRequest:(NSMutableURLRequest *)request withUsername:(NSString *)username andPassword:(NSString *)password;

@end
