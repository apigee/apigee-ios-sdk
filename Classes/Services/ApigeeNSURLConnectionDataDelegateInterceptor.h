//
//  ApigeeNSURLConnectionDataDelegateInterceptor.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApigeeNSURLConnectionDataDelegateInterceptor : NSObject <NSURLConnectionDelegate,
                NSURLConnectionDataDelegate,
                NSURLConnectionDownloadDelegate>
{
    BOOL _connectionAlive;
}


@property(strong) NSDate *createTime;
@property(strong) NSURL* url;

- (id) initAndInterceptFor:(id) target;

- (BOOL)isConnectionAlive;

@end