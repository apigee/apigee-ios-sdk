//
//  ApigeeNSURLSessionDataDelegateInterceptor.h
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 10/4/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @internal
 */
@interface ApigeeNSURLSessionDataDelegateInterceptor : NSObject <NSURLSessionDelegate,NSURLSessionDataDelegate>

- (id) initAndInterceptFor:(id)target;

@end
