/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <objc/runtime.h>

#import "ApigeeNSURLConnectionDataDelegateInterceptor.h"
#import "ApigeeURLConnection.h"
#import "NSURLConnection+Apigee.h"
#import "ApigeeMonitoringClient.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeMonitoringClient.h"
#import "ApigeeSessionMetricsCompiler.h"
#import "ApigeeAppIdentification.h"
#import "NSString+UUID.h"

static void *KEY_CONNECTION_INTERCEPTOR;

typedef void (^NSURLConnectionAsyncRequestCompletionHandler)(NSURLResponse* response, NSData* data, NSError* connectionError);

// Declarations for swizzled methods

//+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
//                  returningResponse:(NSURLResponse **)response
//                              error:(NSError **)error
NSData* (*gOrigNSURLConnection_sendSynchronousRequestReturningResponseError)(id,SEL,NSURLRequest*,NSURLResponse**,NSError**) = NULL;

//+ (void)sendAsynchronousRequest:(NSURLRequest*) request
//                          queue:(NSOperationQueue*) queue
//              completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler;
void (*gOrigNSURLConnection_sendAsynchronousRequestQueueCompletionHandler)(id,SEL,NSURLRequest*,NSOperationQueue*,NSURLConnectionAsyncRequestCompletionHandler) = NULL;

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
    
    //TODO: pass in non-null response object even if caller hasn't (so that
    // we can relay the HTTP status code information to the server)
    
    if (gOrigNSURLConnection_sendSynchronousRequestReturningResponseError != NULL) {
        
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry recordStartTime];

        NSData *responseData;
        NSError *reportingError = nil;
        
        ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [monitoringClient injectApigeeHttpHeaders: mutableRequest];
        request = [mutableRequest copy];
       
       
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
       
        if (![monitoringClient isPaused]) {
            [entry recordEndTime];
    
            [entry populateWithRequest:request];
    
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
                                  @"unable to capture networking error: %@",
                                  [exception reason]);
                }
            }
    
            [monitoringClient recordNetworkEntry:entry];
        } else {
            NSLog(@"Not capturing network metrics -- paused");
        }
        
        return responseData;
    } else {
        return nil;
    }
}

static void NSURLConnection_apigeeSendAsynchronousRequestQueueCompletionHandler(id self,SEL _cmd,NSURLRequest* request,NSOperationQueue* queue,NSURLConnectionAsyncRequestCompletionHandler handler)
{
    if (gOrigNSURLConnection_sendAsynchronousRequestQueueCompletionHandler != NULL) {

        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry recordStartTime];

        ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [monitoringClient injectApigeeHttpHeaders: mutableRequest];
        request = [mutableRequest copy];

        gOrigNSURLConnection_sendAsynchronousRequestQueueCompletionHandler(self,_cmd,request,queue,^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (![monitoringClient isPaused])
            {
                [entry recordEndTime];
                [entry populateWithRequest:request];

                if (response != nil) {
                    [entry populateWithResponse:response];
                }

                if (data != nil) {
                    [entry populateWithResponseData:data];
                    @try {
                        if ( connectionError != nil ) {
                            [entry populateWithError:connectionError];
                        }
                    } @catch (NSException* exception) {
                        ApigeeLogWarn(@"MONITOR_CLIENT",@"unable to capture networking error: %@",[exception reason]);
                    }
                }

                [monitoringClient recordNetworkEntry:entry];
            }
            else
            {
                NSLog(@"Not capturing network metrics -- paused");
            }

            if( handler ) {
                handler(response,data,connectionError);
            }
        });
    }
}

static ApigeeNSURLConnectionDataDelegateInterceptor* GetConnectionInterceptor(NSURLConnection* connection)
{
    return (ApigeeNSURLConnectionDataDelegateInterceptor*)
        objc_getAssociatedObject(connection, &KEY_CONNECTION_INTERCEPTOR);
}

static void AttachConnectionInterceptor(NSURLConnection* connection,
                                        ApigeeNSURLConnectionDataDelegateInterceptor* interceptor)
{
    objc_setAssociatedObject(connection,
                             &KEY_CONNECTION_INTERCEPTOR,
                             interceptor,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static NSURLConnection* NSURLConnection_apigeeConnectionWithRequestDelegate(id self,SEL _cmd,NSURLRequest* request,id delegate)
{
    //ApigeeLogVerbose(@"MOBILE_AGENT", @"NSURLConnection_apigeeConnectionWithRequestDelegate");
    
    if (gOrigNSURLConnection_connectionWithRequestDelegate != NULL) {
        ApigeeNSURLConnectionDataDelegateInterceptor *interceptor =
        [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                      withRequest:request];
        
        NSURLConnection* connection = (NSURLConnection*) self;
        if (![connection isKindOfClass:[ApigeeURLConnection class]]) {
            AttachConnectionInterceptor(connection, interceptor);
        }
        
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
       
        ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [monitoringClient injectApigeeHttpHeaders: mutableRequest];
        request = [mutableRequest copy];
        

        NSURLConnection* connection = (NSURLConnection*) self;
        if (![connection isKindOfClass:[ApigeeURLConnection class]]) {
            AttachConnectionInterceptor(connection, interceptor);
        }

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
        
        ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [monitoringClient injectApigeeHttpHeaders: mutableRequest];
        request = [mutableRequest copy];
        
       // NSLog (@"Printing all http headers");
        //NSLog(@"%@", [request allHTTPHeaderFields]);
        
        NSURLConnection* connection = (NSURLConnection*) self;
        if (![connection isKindOfClass:[ApigeeURLConnection class]]) {
            AttachConnectionInterceptor(connection, interceptor);
        }

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
    
    NSURLConnection* connection = (NSURLConnection*)self;
    
    if (![connection isKindOfClass:[ApigeeURLConnection class]]) {
        ApigeeNSURLConnectionDataDelegateInterceptor* interceptor =
            GetConnectionInterceptor(connection);
        if (interceptor) {
            [interceptor recordStartTime];
        }
    }
    
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
    if( impOverrideMethod != method_getImplementation(origMethod) )
    {
        gOrigNSURLConnection_sendSynchronousRequestReturningResponseError = (void *)method_getImplementation(origMethod);

        if( gOrigNSURLConnection_sendSynchronousRequestReturningResponseError != NULL )
        {
            method_setImplementation(origMethod, impOverrideMethod);
            ++numSwizzledMethods;
        } else {
            NSLog(@"error: unable to swizzle +sendSynchronousRequest:returningResponse:error:");
        }
    }

    //***********************************
    // NSURLConnection +sendAsynchronousRequest:queue:completionHandler:
    selMethod = @selector(sendAsynchronousRequest:queue:completionHandler:);
    impOverrideMethod = (IMP) NSURLConnection_apigeeSendAsynchronousRequestQueueCompletionHandler;
    origMethod = class_getClassMethod(c,selMethod);
    if( impOverrideMethod != method_getImplementation(origMethod) )
    {
        gOrigNSURLConnection_sendAsynchronousRequestQueueCompletionHandler = (void *)method_getImplementation(origMethod);

        if( gOrigNSURLConnection_sendAsynchronousRequestQueueCompletionHandler != NULL )
        {
            method_setImplementation(origMethod, impOverrideMethod);
            ++numSwizzledMethods;
        } else {
            NSLog(@"error: unable to swizzle +sendAsynchronousRequest:queue:completionHandler");
        }
    }

    //***********************************
    // NSURLConnection +connectionWithRequest:delegate:
    selMethod = @selector(connectionWithRequest:delegate:);
    impOverrideMethod = (IMP) NSURLConnection_apigeeConnectionWithRequestDelegate;
    origMethod = class_getClassMethod(c,selMethod);
    if( impOverrideMethod != method_getImplementation(origMethod) )
    {
        gOrigNSURLConnection_connectionWithRequestDelegate = (void *)method_getImplementation(origMethod);

        if( gOrigNSURLConnection_connectionWithRequestDelegate != NULL )
        {
            method_setImplementation(origMethod, impOverrideMethod);
            ++numSwizzledMethods;
        } else {
            NSLog(@"error: unable to swizzle +connectionWithRequest:delegate:");
        }
    }

    //***********************************
    // NSURLConnection -initWithRequest:delegate:startImmediately:
    selMethod = @selector(initWithRequest:delegate:startImmediately:);
    impOverrideMethod = (IMP) NSURLConnection_apigeeInitWithRequestDelegateStartImmediately;
    origMethod = class_getInstanceMethod(c,selMethod);
    if( impOverrideMethod != method_getImplementation(origMethod) )
    {
        gOrigNSURLConnection_initWithRequestDelegateStartImmediately = (void *)method_getImplementation(origMethod);

        if( gOrigNSURLConnection_initWithRequestDelegateStartImmediately != NULL )
        {
            method_setImplementation(origMethod, impOverrideMethod);
            ++numSwizzledMethods;
        } else {
            NSLog(@"error: unable to swizzle -initWithRequest:delegate:startImmediately:");
        }
    }

    //***********************************
    // NSURLConnection -initWithRequest:delegate:
    selMethod = @selector(initWithRequest:delegate:);
    impOverrideMethod = (IMP) NSURLConnection_apigeeInitWithRequestDelegate;
    origMethod = class_getInstanceMethod(c,selMethod);
    if( impOverrideMethod != method_getImplementation(origMethod) )
    {
        gOrigNSURLConnection_initWithRequestDelegate = (void *)method_getImplementation(origMethod);

        if( gOrigNSURLConnection_initWithRequestDelegate != NULL )
        {
            method_setImplementation(origMethod, impOverrideMethod);
            ++numSwizzledMethods;
        } else {
            NSLog(@"error: unable to swizzle -initWithRequest:delegate:");
        }
    }


    //***********************************
    // NSURLConnection -start
    selMethod = @selector(start);
    impOverrideMethod = (IMP) NSURLConnection_apigeeStart;
    origMethod = class_getInstanceMethod(c,selMethod);
    if( impOverrideMethod != method_getImplementation(origMethod) )
    {
        gOrigNSURLConnection_start = (void *)method_getImplementation(origMethod);

        if( gOrigNSURLConnection_start != NULL )
        {
            method_setImplementation(origMethod, impOverrideMethod);
            ++numSwizzledMethods;
        } else {
            NSLog(@"error: unable to swizzle -start");
        }
    }

    return (numSwizzledMethods == 6);
}

@end
