//
//  NSURLConnection+Apigee.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (Apigee)

+ (NSURLConnection*) timedConnectionWithRequest:(NSURLRequest *) request
                                       delegate:(id < NSURLConnectionDelegate >) delegate;
+ (NSData *) timedSendSynchronousRequest:(NSURLRequest *) request
                       returningResponse:(NSURLResponse **)response
                                   error:(NSError **)error;
+ (void) timedSendAsynchronousRequest:(NSURLRequest *)request
                                queue:(NSOperationQueue *)queue
                    completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;


- (id) initTimedConnectionWithRequest:(NSURLRequest *)request
                             delegate:(id < NSURLConnectionDelegate >)delegate;
- (id) initTimedConnectionWithRequest:(NSURLRequest *)request
                             delegate:(id < NSURLConnectionDelegate >) delegate
                     startImmediately:(BOOL) startImmediately;


// ******  swizzling  *******

+ (NSData*) swzSendSynchronousRequest:(NSURLRequest *) request
                    returningResponse:(NSURLResponse **)response
                                error:(NSError **)error;
+ (NSURLConnection *)swzConnectionWithRequest:(NSURLRequest *)request
                                     delegate:(id < NSURLConnectionDelegate >)delegate;
- (id) initSwzWithRequest:(NSURLRequest *) request
                 delegate:(id < NSURLConnectionDelegate >)delegate
         startImmediately:(BOOL) startImmediately;
- (void) swzStart;

- (NSDate*)startTime;
- (void)setStartTime:(NSDate*)theStartTime;

@end
