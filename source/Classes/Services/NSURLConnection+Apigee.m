//
//  NSURLConnection+Apigee.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <objc/runtime.h>

#import "ApigeeNSURLConnectionDataDelegateInterceptor.h"
#import "ApigeeURLConnection.h"
#import "NSURLConnection+Apigee.h"
#import "ApigeeMonitoringClient.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeMonitoringClient.h"

static void *KEY_START_TIME;


@implementation NSURLConnection (Apigee)

+ (NSURLConnection*) timedConnectionWithRequest:(NSURLRequest *) request
                                       delegate:(id < NSURLConnectionDelegate >) delegate
{
    return [ApigeeURLConnection connectionWithRequest:request
                                               delegate:delegate];
}

+ (NSData *) timedSendSynchronousRequest:(NSURLRequest *) request
                       returningResponse:(NSURLResponse **)response
                                   error:(NSError **)error
{
    return [ApigeeURLConnection sendSynchronousRequest:request
                                       returningResponse:response
                                                   error:error];
}

+ (void)timedSendAsynchronousRequest:(NSURLRequest *)request
                               queue:(NSOperationQueue *)queue
                   completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    [ApigeeURLConnection sendAsynchronousRequest:request
                                             queue:queue
                                 completionHandler:handler];
}

- (id) initTimedConnectionWithRequest:(NSURLRequest *)request
                             delegate:(id < NSURLConnectionDelegate >)delegate
{
    if ([self isKindOfClass:[ApigeeURLConnection class]]) {
         return [self initWithRequest:request delegate:delegate];
    }
    
    return [[ApigeeURLConnection alloc] initWithRequest:request
                                                 delegate:delegate];
}

- (id) initTimedConnectionWithRequest:(NSURLRequest *)request
                             delegate:(id < NSURLConnectionDelegate >) delegate
                     startImmediately:(BOOL) startImmediately
{
    if ([self isKindOfClass:[ApigeeURLConnection class]]) {
        return [self initWithRequest:request
                            delegate:delegate
                    startImmediately:startImmediately];
    }

    return [[ApigeeURLConnection alloc] initWithRequest:request
                                                 delegate:delegate
                                         startImmediately:startImmediately];
}


//******************************************************************************
//******************************************************************************

+ (NSData*) swzSendSynchronousRequest:(NSURLRequest *) request
                    returningResponse:(NSURLResponse **)response
                                error:(NSError **)error
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"swzSendSynchronousRequest");

    NSDate *startTime = [NSDate date];
    
    //TODO: pass in non-null error object even if caller hasn't (so that
    // we can relay the error information to the server)
    
    // this looks like a recursive call, but it's not (swizzling)
    NSData *responseData = [self swzSendSynchronousRequest:request
                                           returningResponse:response
                                                       error:error];
    
    NSDate *endTime = [NSDate date];
    
    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
    [entry populateWithRequest:request];
    [entry populateStartTime:startTime ended:endTime];
    
    if (response && *response) {
        NSURLResponse *theResponse = *response;
        [entry populateWithResponse:theResponse];
    }
    
    [entry populateWithResponseData:responseData];
    
    if (error && *error) {
        NSError *theError = *error;
        [entry populateWithError:theError];
    }
    
    [[ApigeeMonitoringClient sharedInstance] recordNetworkEntry:entry];
    
    return responseData;
}

+ (NSURLConnection *)swzConnectionWithRequest:(NSURLRequest *)request
                                     delegate:(id < NSURLConnectionDelegate >)delegate
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"swzConnectionWithRequest");

    ApigeeNSURLConnectionDataDelegateInterceptor *interceptor =
    [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                  withRequest:request];
    // the following looks like a recursive call, but it isn't (swizzling)
    return [NSURLConnection swzConnectionWithRequest:request delegate:interceptor];
}

- (id) initSwzWithRequest:(NSURLRequest *) request
                 delegate:(id < NSURLConnectionDelegate >)delegate
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"initSwzWithRequest");
    
    ApigeeNSURLConnectionDataDelegateInterceptor *interceptor =
    [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                  withRequest:request];
    // the following looks like a recursive call, but it isn't (swizzling)
    return [self initSwzWithRequest:request
                           delegate:interceptor];
}

- (id) initSwzWithRequest:(NSURLRequest *) request
                 delegate:(id < NSURLConnectionDelegate >)delegate
         startImmediately:(BOOL) startImmediately
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"initSwzWithRequest");

    ApigeeNSURLConnectionDataDelegateInterceptor *interceptor =
    [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                  withRequest:request];
    // the following looks like a recursive call, but it isn't (swizzling)
    return [self initSwzWithRequest:request
                           delegate:interceptor
                   startImmediately:startImmediately];
}

- (void) swzStart
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"swzStart");

    [self setStartTime:[NSDate date]];
    
    // the following looks like a recursive call, but it isn't (swizzling)
    [self swzStart];
}

- (NSDate*)startTime
{
    NSDate* theStartTime = nil;
    
    if( [self isKindOfClass:[ApigeeURLConnection class]] )
    {
        theStartTime = ((ApigeeURLConnection *)self).started;
    }
    
    if( ! theStartTime )
    {
        theStartTime = (NSDate*) objc_getAssociatedObject(self, &KEY_START_TIME);
    }
    
    return theStartTime;
}

- (void)setStartTime:(NSDate*)theStartTime
{
    if( [self isKindOfClass:[ApigeeURLConnection class]] )
    {
        ApigeeURLConnection* ioUrlConnection = (ApigeeURLConnection*) self;
        ioUrlConnection.started = theStartTime;
    }
    else
    {
        //attach the start time to ourselves
        objc_setAssociatedObject(self,
                                 &KEY_START_TIME,
                                 theStartTime,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
