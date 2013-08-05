//
//  ApigeeHTTPClient.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//
#import <Foundation/Foundation.h>

@class ApigeeHTTPResult;

typedef void (^ApigeeHTTPCompletionHandler)(ApigeeHTTPResult *result);
typedef void (^ApigeeHTTPProgressHandler)(CGFloat progress);

@interface ApigeeHTTPClient : NSObject
#if TARGET_OS_IPHONE
<NSURLConnectionDataDelegate>
#endif

@property (nonatomic, copy) ApigeeHTTPCompletionHandler completionHandler;
@property (nonatomic, copy) ApigeeHTTPProgressHandler progressHandler;
@property (readonly) CGFloat progress;
@property (readonly) BOOL isRunning;

- (id) initWithRequest:(NSMutableURLRequest *) request;

// make synchronous connection
- (ApigeeHTTPResult *) connect;

- (void) connectWithCompletionHandler:(ApigeeHTTPCompletionHandler) completionHandler;

- (void) connectWithCompletionHandler:(ApigeeHTTPCompletionHandler) completionHandler
                      progressHandler:(ApigeeHTTPProgressHandler) progressHandler;

- (void) cancel;

@end
