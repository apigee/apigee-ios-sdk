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
 @discussion This class provides a convenient mechanism for making HTTP requests
 with callback blocks.
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
 Initialize with an NSMutableURLRequest
 @param request the request to execute
 */
- (id) initWithRequest:(NSMutableURLRequest *) request;

/*!
 Make synchronous connection and calls completion handler if one is set
 @return result object indicating success/failure and corresponding data
 */
- (ApigeeHTTPResult *) connect;

/*!
 Makes connection and informs handler of completion
 @param completionHandler the completion handler to invoke on completion of request
 */
- (void) connectWithCompletionHandler:(void (^)(ApigeeHTTPResult *result)) completionHandler;

/*!
 Makes connection and informs handlers of progress and completion
 @param completionHandler the completion handler to invoke on completion of request
 @param progressHandler the handler to invoke (possibly repeatedly) and notify of request progress
 */
- (void) connectWithCompletionHandler:(void (^)(ApigeeHTTPResult *result)) completionHandler
                      progressHandler:(void (^)(CGFloat progress)) progressHandler;

/*!
 Cancels the network request
 */
- (void) cancel;

@end
