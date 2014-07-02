/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


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
