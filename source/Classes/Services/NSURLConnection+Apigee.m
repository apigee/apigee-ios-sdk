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


// Declarations for swizzled methods

//+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
//                  returningResponse:(NSURLResponse **)response
//                              error:(NSError **)error
NSData* (*gOrigNSURLConnection_sendSynchronousRequestReturningResponseError)(id,SEL,NSURLRequest*,NSURLResponse**,NSError**) = NULL;

//+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request
//                                  delegate:(id < NSURLConnectionDelegate >)delegate
NSURLConnection* (*gOrigNSURLConnection_connectionWithRequestDelegate)(id,SEL,NSURLRequest*,id) = NULL;

//- (id)initWithRequest:(NSURLRequest *)request
//            delegate:(id < NSURLConnectionDelegate >)delegate
//    startImmediately:(BOOL)startImmediately
id (*gOrigNSURLConnection_initWithRequestDelegateStartImmediately)(id,SEL,NSURLRequest*,id,BOOL) = NULL;

//- (id)initWithRequest:(NSURLRequest *)request
//            delegate:(id < NSURLConnectionDelegate >)delegate
id (*gOrigNSURLConnection_initWithRequestDelegate)(id,SEL,NSURLRequest*,id) = NULL;

//- (void)start
void (*gOrigNSURLConnection_start)(id,SEL) = NULL;



static NSData* NSURLConnection_apigeeSendSynchronousRequestReturningResponseError(id self,SEL _cmd,NSURLRequest* request,NSURLResponse** response,NSError** error)
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"NSURLConnection_apigeeSendSynchronousRequestReturningResponseError");
    
    
    //TODO: pass in non-null error object even if caller hasn't (so that
    // we can relay the error information to the server)
    
    if (gOrigNSURLConnection_sendSynchronousRequestReturningResponseError != NULL) {
        
        NSDate *startTime = [NSDate date];

        NSData *responseData;
        NSError *reportingError = nil;
        
        if (error != nil) {
            responseData =
                gOrigNSURLConnection_sendSynchronousRequestReturningResponseError(self,
                                                                              _cmd,
                                                                              request,
                                                                              response,
                                                                              error);
        } else {
            responseData =
                gOrigNSURLConnection_sendSynchronousRequestReturningResponseError(self,
                                                                              _cmd,
                                                                              request,
                                                                              response,
                                                                              &reportingError);
        }
    
        NSDate *endTime = [NSDate date];
    
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithRequest:request];
        [entry populateStartTime:startTime ended:endTime];
    
        if (response && *response) {
            NSURLResponse *theResponse = *response;
            [entry populateWithResponse:theResponse];
        }
    
        [entry populateWithResponseData:responseData];
    
        if (nil == responseData) {
            @try {
                if ( error && *error) {
                    NSError *theError = *error;
                    [entry populateWithError:theError];
                } else if (reportingError != nil) {
                    [entry populateWithError:reportingError];
                }
            } @catch (NSException* exception) {
                ApigeeLogWarn(@"MONITOR_CLIENT",
                              @"unable to capture potential networking error: %@",
                              [exception reason]);
            }
        }
    
        [[ApigeeMonitoringClient sharedInstance] recordNetworkEntry:entry];
    
        return responseData;
    } else {
        return nil;
    }
}


static NSURLConnection* NSURLConnection_apigeeConnectionWithRequestDelegate(id self,SEL _cmd,NSURLRequest* request,id delegate)
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"NSURLConnection_apigeeConnectionWithRequestDelegate");

    if (gOrigNSURLConnection_connectionWithRequestDelegate != NULL) {
        ApigeeNSURLConnectionDataDelegateInterceptor *interceptor =
        [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                      withRequest:request];
        return gOrigNSURLConnection_connectionWithRequestDelegate(self,_cmd,request,interceptor);
    } else {
        return nil;
    }
}

static id NSURLConnection_apigeeInitWithRequestDelegateStartImmediately(id self,SEL _cmd,NSURLRequest* request,id delegate,BOOL startImmediately)
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"NSURLConnection_apigeeInitWithRequestDelegateStartImmediately");
    
    if (gOrigNSURLConnection_initWithRequestDelegateStartImmediately) {
        ApigeeNSURLConnectionDataDelegateInterceptor *interceptor =
        [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                      withRequest:request];

        return gOrigNSURLConnection_initWithRequestDelegateStartImmediately(self,
                                                                            _cmd,
                                                                            request,
                                                                            interceptor,
                                                                            startImmediately);
    } else {
        return nil;
    }
}

static id NSURLConnection_apigeeInitWithRequestDelegate(id self,SEL _cmd,NSURLRequest* request,id delegate)
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"NSURLConnection_apigeeInitWithRequestDelegate");
    
    if (gOrigNSURLConnection_initWithRequestDelegate) {
        ApigeeNSURLConnectionDataDelegateInterceptor *interceptor =
        [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                      withRequest:request];

        return gOrigNSURLConnection_initWithRequestDelegate(self,
                                                            _cmd,
                                                            request,
                                                            interceptor);
    } else {
        return nil;
    }
}

static void NSURLConnection_apigeeStart(id self,SEL _cmd)
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"NSURLConnection_apigeeStart");
    
    [self setStartTime:[NSDate date]];
    
    if (gOrigNSURLConnection_start != NULL) {
        gOrigNSURLConnection_start(self,_cmd);
    }
}



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

+ (BOOL)apigeeSwizzlingSetup
{
    SEL selMethod;
    IMP impOverrideMethod;
    Method origMethod;
    int numSwizzledMethods = 0;
    Class c = [NSURLConnection class];
    
    
    //***********************************
    // NSURLConnection +sendSynchronousRequest:returningResponse:error:
    selMethod = @selector(sendSynchronousRequest:returningResponse:error:);
    impOverrideMethod = (IMP) NSURLConnection_apigeeSendSynchronousRequestReturningResponseError;
    origMethod = class_getClassMethod(c,selMethod);
    gOrigNSURLConnection_sendSynchronousRequestReturningResponseError = (void *)method_getImplementation(origMethod);
    
    if( gOrigNSURLConnection_sendSynchronousRequestReturningResponseError != NULL )
    {
        method_setImplementation(origMethod, impOverrideMethod);
        ++numSwizzledMethods;
    } else {
        NSLog(@"error: unable to swizzle +sendSynchronousRequest:returningResponse:error:");
    }

    
    //***********************************
    // NSURLConnection +connectionWithRequest:delegate:
    selMethod = @selector(connectionWithRequest:delegate:);
    impOverrideMethod = (IMP) NSURLConnection_apigeeConnectionWithRequestDelegate;
    origMethod = class_getClassMethod(c,selMethod);
    gOrigNSURLConnection_connectionWithRequestDelegate = (void *)method_getImplementation(origMethod);
    
    if( gOrigNSURLConnection_connectionWithRequestDelegate != NULL )
    {
        method_setImplementation(origMethod, impOverrideMethod);
        ++numSwizzledMethods;
    } else {
        NSLog(@"error: unable to swizzle +connectionWithRequest:delegate:");
    }


    //***********************************
    // NSURLConnection -initWithRequest:delegate:startImmediately:
    selMethod = @selector(initWithRequest:delegate:startImmediately:);
    impOverrideMethod = (IMP) NSURLConnection_apigeeInitWithRequestDelegateStartImmediately;
    origMethod = class_getInstanceMethod(c,selMethod);
    gOrigNSURLConnection_initWithRequestDelegateStartImmediately = (void *)method_getImplementation(origMethod);
    
    if( gOrigNSURLConnection_initWithRequestDelegateStartImmediately != NULL )
    {
        method_setImplementation(origMethod, impOverrideMethod);
        ++numSwizzledMethods;
    } else {
        NSLog(@"error: unable to swizzle -initWithRequest:delegate:startImmediately:");
    }

    
    //***********************************
    // NSURLConnection -initWithRequest:delegate:
    selMethod = @selector(initWithRequest:delegate:);
    impOverrideMethod = (IMP) NSURLConnection_apigeeInitWithRequestDelegate;
    origMethod = class_getInstanceMethod(c,selMethod);
    gOrigNSURLConnection_initWithRequestDelegate = (void *)method_getImplementation(origMethod);
    
    if( gOrigNSURLConnection_initWithRequestDelegate != NULL )
    {
        method_setImplementation(origMethod, impOverrideMethod);
        ++numSwizzledMethods;
    } else {
        NSLog(@"error: unable to swizzle -initWithRequest:delegate:");
    }

    
    //***********************************
    // NSURLConnection -start
    selMethod = @selector(start);
    impOverrideMethod = (IMP) NSURLConnection_apigeeStart;
    origMethod = class_getInstanceMethod(c,selMethod);
    gOrigNSURLConnection_start = (void *)method_getImplementation(origMethod);
    
    if( gOrigNSURLConnection_start != NULL )
    {
        method_setImplementation(origMethod, impOverrideMethod);
        ++numSwizzledMethods;
    } else {
        NSLog(@"error: unable to swizzle -start");
    }
    
    return (numSwizzledMethods == 5);
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
