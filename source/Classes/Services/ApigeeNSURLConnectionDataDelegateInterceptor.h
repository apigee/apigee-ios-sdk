//
//  ApigeeNSURLConnectionDataDelegateInterceptor.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @internal
 */
@interface ApigeeNSURLConnectionDataDelegateInterceptor : NSObject <NSURLConnectionDelegate,
                NSURLConnectionDataDelegate,
                NSURLConnectionDownloadDelegate>
{
    BOOL _connectionAlive;
}


@property(strong) NSDate *createTime;

- (id) initAndInterceptFor:(id) target withRequest:(NSURLRequest*)request;

- (BOOL)isConnectionAlive;

@end