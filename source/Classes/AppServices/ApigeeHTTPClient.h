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

/*!
 @class ApigeeHTTPClient
 @abstract
 */
@interface ApigeeHTTPClient : NSObject
#if TARGET_OS_IPHONE
<NSURLConnectionDataDelegate>
#endif

@property (nonatomic, copy) ApigeeHTTPCompletionHandler completionHandler;
@property (nonatomic, copy) ApigeeHTTPProgressHandler progressHandler;
@property (readonly) CGFloat progress;
@property (readonly) BOOL isRunning;

/*!
 @abstract
 @param request
 */
- (id) initWithRequest:(NSMutableURLRequest *) request;

/*!
 @abstract make synchronous connection
 @return ApigeeHTTPResult instance
 @see ApigeeHTTPResult ApigeeHTTPResult
 */
- (ApigeeHTTPResult *) connect;

/*!
 @abstract
 @param completionHandler
 */
- (void) connectWithCompletionHandler:(ApigeeHTTPCompletionHandler) completionHandler;

/*!
 @abstract
 @param completionHandler
 @param progressHandler
 */
- (void) connectWithCompletionHandler:(ApigeeHTTPCompletionHandler) completionHandler
                      progressHandler:(ApigeeHTTPProgressHandler) progressHandler;

/*!
 @abstract
 */
- (void) cancel;

@end
