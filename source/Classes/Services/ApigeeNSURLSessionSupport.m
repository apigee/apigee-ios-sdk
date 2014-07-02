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

#import "ApigeeNSURLSessionSupport.h"

#include <objc/runtime.h>

#import "ApigeeMonitoringClient.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeNSURLSessionDataTaskInfo.h"
#import "ApigeeNSURLSessionDataDelegateInterceptor.h"
#import "ApigeeAppIdentification.h"


NSURLSession* (*gOrigNSURLSession_sessionWithConfigurationDelegateAndQueue)(id,SEL,NSURLSessionConfiguration*,id,NSOperationQueue*) = NULL;
void (*gOrigNSCFLocalDataTask_resume)(id,SEL) = NULL;
void (*gOrigNSURLSessionTask_resume)(id,SEL) = NULL;
NSURLSessionDataTask* (*gOrigDataTaskWithURLAndCompletionHandler)(id, SEL, NSURL*, DataTaskCompletionBlock) = NULL;
NSURLSessionDataTask* (*gOrigDataTaskWithRequestAndCompletionHandler)(id, SEL, NSURLRequest*, DataTaskCompletionBlock) = NULL;



static NSURLSession* NSURLSession_apigeeSessionWithConfigurationDelegateAndQueue(id self, SEL _cmd,NSURLSessionConfiguration* configuration,id delegate,NSOperationQueue* queue)
{
    NSURLSession* session = nil;
   
    if (configuration != nil) {
        ApigeeMonitoringClient *monitoringClient = [ApigeeMonitoringClient sharedInstance];
        [configuration setHTTPAdditionalHeaders:@{
            @"X-Apigee-Client-Device-Id" : [monitoringClient apigeeDeviceId],
            @"X-Apigee-Client-Sessiond-Id":[[NSUserDefaults standardUserDefaults] objectForKey:@"kApigeeSessionIdKey"],
            @"X-Apigee-Client-Org-Name" : [[monitoringClient appIdentification] organizationId],
            @"X-Apigee-Client-App-Name" : [[monitoringClient appIdentification] applicationId]
        }];
    }
    
    if( delegate != nil )
    {
        // execute original implementation with our delegate interceptor (wrapper)
        ApigeeNSURLSessionDataDelegateInterceptor* interceptor =
        [[ApigeeNSURLSessionDataDelegateInterceptor alloc] initAndInterceptFor:delegate];
        session = gOrigNSURLSession_sessionWithConfigurationDelegateAndQueue(self,
                                                                             _cmd,
                                                                             configuration,
                                                                             interceptor,
                                                                             queue);
    }
    else
    {
        // execute original implementation unchanged
        session = gOrigNSURLSession_sessionWithConfigurationDelegateAndQueue(self,
                                                                             _cmd,
                                                                             configuration,
                                                                             delegate,
                                                                             queue);
    }
    
    return session;
}

static void NSCFLocalDataTask_apigeeResume(id self, SEL _cmd)
{
    // set the starting time for this data task
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    [monitoringClient recordStartTimeForSessionDataTask:self];
    
    // execute original implementation of 'resume' method
    gOrigNSCFLocalDataTask_resume(self,_cmd);
}

static void NSURLSessionTask_apigeeResume(id self, SEL _cmd)
{
    // set the starting time for this data task
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    [monitoringClient recordStartTimeForSessionDataTask:self];
    
    // execute original implementation of 'resume' method
    gOrigNSURLSessionTask_resume(self,_cmd);
}

static NSURLSessionDataTask* NSCFURLSession_apigeeDataTaskWithURLAndCompletionHandler(id self, SEL _cmd, NSURL* url, DataTaskCompletionBlock completionHandler)
{
    NSURLSessionDataTask* sessionDataTask = nil;
    
    if( completionHandler ) {
        ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
        const BOOL monitoringPaused = [monitoringClient isPaused];
        id dataTaskIdentifier = [monitoringClient generateIdentifierForDataTask];
        
        // execute original implementation but with our own completion handler
        sessionDataTask =
        gOrigDataTaskWithURLAndCompletionHandler(self,_cmd,url,^(NSData *data,
                                                                 NSURLResponse *response,
                                                                 NSError *error) {
            
            ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
            [monitoringClient dataTaskInfoForIdentifier:dataTaskIdentifier];

            if (!monitoringPaused) {
                [sessionDataTaskInfo.networkEntry recordEndTime];
            
                [sessionDataTaskInfo.networkEntry populateWithResponseData:data];
                [sessionDataTaskInfo.networkEntry populateWithResponse:response];
                [sessionDataTaskInfo.networkEntry populateWithError:error];
            
                [monitoringClient recordNetworkEntry:sessionDataTaskInfo.networkEntry];
            } else {
                NSLog(@"Not capturing network metrics -- paused");
            }
            
            // do we have a completion handler?
            if( sessionDataTaskInfo.completionHandler ) {
                // run the completion handler
                sessionDataTaskInfo.completionHandler(data,response,error);
            }
            
            [monitoringClient removeDataTaskInfoForIdentifier:dataTaskIdentifier];
        });

        ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
        [[ApigeeNSURLSessionDataTaskInfo alloc] init];

        if (!monitoringPaused) {
            ApigeeNetworkEntry* networkEntry = [[ApigeeNetworkEntry alloc] init];
            [networkEntry populateWithURL:url];
            sessionDataTaskInfo.networkEntry = networkEntry;
        }
        
        sessionDataTaskInfo.sessionDataTask = sessionDataTask;
        sessionDataTaskInfo.completionHandler = completionHandler;
        sessionDataTaskInfo.key = dataTaskIdentifier;
        
        [monitoringClient registerDataTaskInfo:sessionDataTaskInfo
                                withIdentifier:dataTaskIdentifier];

    } else {
        // execute original implementation with no changes
        sessionDataTask =
        gOrigDataTaskWithURLAndCompletionHandler(self,_cmd,url,completionHandler);
    }
    
    return sessionDataTask;
}

static NSURLSessionDataTask* NSCFURLSession_apigeeDataTaskWithRequestAndCompletionHandler(id self, SEL _cmd, NSURLRequest* request, DataTaskCompletionBlock completionHandler)
{
    

    NSURLSessionDataTask* sessionDataTask = nil;
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    const BOOL monitoringPaused = [monitoringClient isPaused];
    id dataTaskIdentifier = [monitoringClient generateIdentifierForDataTask];
    
    if (request != nil) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [monitoringClient injectApigeeHttpHeaders: mutableRequest];
        request = [mutableRequest copy];
    }
    
    if( completionHandler ) {
        
        // execute original implementation with our own completion handler
        sessionDataTask =
        gOrigDataTaskWithRequestAndCompletionHandler(self,_cmd,request,^(NSData *data,
                                                                         NSURLResponse *response,
                                                                         NSError *error) {
            
            ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
            [monitoringClient dataTaskInfoForIdentifier:dataTaskIdentifier];
            
            if (!monitoringPaused) {
                [sessionDataTaskInfo.networkEntry recordEndTime];

                [sessionDataTaskInfo.networkEntry populateWithResponseData:data];
                [sessionDataTaskInfo.networkEntry populateWithResponse:response];
                [sessionDataTaskInfo.networkEntry populateWithError:error];
            
                [monitoringClient recordNetworkEntry:sessionDataTaskInfo.networkEntry];
            } else {
                NSLog(@"Not capturing network metrics -- paused");
            }
            
            // do we have a completion handler?
            if( sessionDataTaskInfo.completionHandler ) {
                // run the completion handler
                sessionDataTaskInfo.completionHandler(data,response,error);
            }
            
            [monitoringClient removeDataTaskInfoForIdentifier:dataTaskIdentifier];
        });
        
    } else {
        // execute original implementation with no changes
        sessionDataTask =
        gOrigDataTaskWithRequestAndCompletionHandler(self,_cmd,request,completionHandler);
    }
    
    
    ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
    [[ApigeeNSURLSessionDataTaskInfo alloc] init];

    if (!monitoringPaused) {
        ApigeeNetworkEntry* networkEntry = [[ApigeeNetworkEntry alloc] init];
        [networkEntry populateWithRequest:request];
        sessionDataTaskInfo.networkEntry = networkEntry;
    }
    
    sessionDataTaskInfo.sessionDataTask = sessionDataTask;
    sessionDataTaskInfo.completionHandler = completionHandler;
    sessionDataTaskInfo.key = dataTaskIdentifier;
    
    [monitoringClient registerDataTaskInfo:sessionDataTaskInfo
                            withIdentifier:dataTaskIdentifier];
    
    return sessionDataTask;
}

@implementation ApigeeNSURLSessionSupport

+ (BOOL)setupAtStartup
{
    Class c;
    SEL selMethod;
    IMP impOverrideMethod;
    Method origMethod;
    
    
    //***********************************
    // NSURLSession +sessionWithConfiguration:delegate:delegateQueue:
    c = NSClassFromString(@"NSURLSession");
    selMethod = @selector(sessionWithConfiguration:delegate:delegateQueue:);
    impOverrideMethod = (IMP) NSURLSession_apigeeSessionWithConfigurationDelegateAndQueue;
    origMethod = class_getClassMethod(c,selMethod);
    gOrigNSURLSession_sessionWithConfigurationDelegateAndQueue = (void *)method_getImplementation(origMethod);
    
    if( gOrigNSURLSession_sessionWithConfigurationDelegateAndQueue != NULL )
    {
        method_setImplementation(origMethod, impOverrideMethod);
    }
    
    //***********************************
    // NSURLSession dataTaskWithRequest:completionHandler:
    c = NSClassFromString(@"__NSCFURLSession");
    selMethod = @selector(dataTaskWithRequest:completionHandler:);
    impOverrideMethod = (IMP) NSCFURLSession_apigeeDataTaskWithRequestAndCompletionHandler;
    origMethod = class_getInstanceMethod(c, selMethod);
    gOrigDataTaskWithRequestAndCompletionHandler = (void *)method_getImplementation(origMethod);
    
    if( gOrigDataTaskWithRequestAndCompletionHandler != NULL )
    {
        method_setImplementation(origMethod,impOverrideMethod);
    }
    
    //***********************************
    // __NSCFLocalDataTask resume
    c = NSClassFromString(@"__NSCFLocalDataTask");
    selMethod = @selector(resume);
    impOverrideMethod = (IMP) NSCFLocalDataTask_apigeeResume;
    origMethod = class_getInstanceMethod(c,selMethod);
    gOrigNSCFLocalDataTask_resume = (void *)method_getImplementation(origMethod);
    
    if( gOrigNSCFLocalDataTask_resume != NULL )
    {
        method_setImplementation(origMethod,impOverrideMethod);
    }
    
    //***********************************
    // NSURLSessionTask resume
    c = NSClassFromString(@"NSURLSessionTask");
    selMethod = @selector(resume);
    impOverrideMethod = (IMP) NSURLSessionTask_apigeeResume;
    origMethod = class_getInstanceMethod(c,selMethod);
    gOrigNSURLSessionTask_resume = (void *)method_getImplementation(origMethod);
    
    if( gOrigNSURLSessionTask_resume != NULL )
    {
        method_setImplementation(origMethod,impOverrideMethod);
    }
    
    return YES;
}

@end
