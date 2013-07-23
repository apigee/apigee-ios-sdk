//
//  ApigeeURLConnection.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApigeeURLConnection : NSURLConnection

@property (strong) NSDate *started;

+ (NSURLConnection *) connectionWithRequest:(NSURLRequest *) request delegate:(id < NSURLConnectionDelegate >) delegate;
+ (NSData *) sendSynchronousRequest:(NSURLRequest *) request
                       returningResponse:(NSURLResponse **)response
                                   error:(NSError **)error;
+ (void)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;

- (id) initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate;
- (id) initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate startImmediately:(BOOL)startImmediately;
- (void) start;

@end
