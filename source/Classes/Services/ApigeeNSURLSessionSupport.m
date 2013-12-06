//
//  ApigeeNSURLSessionSupport.m
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 10/10/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeNSURLSessionSupport.h"

#include <objc/runtime.h>

#import "ApigeeMonitoringClient.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeNSURLSessionDataTaskInfo.h"
#import "ApigeeNSURLSessionDataDelegateInterceptor.h"


NSURLSession* (*gOrigNSURLSession_sessionWithConfigurationDelegateAndQueue)(id,SEL,NSURLSessionConfiguration*,id,NSOperationQueue*) = NULL;
void (*gOrigNSCFLocalDataTask_resume)(id,SEL) = NULL;
void (*gOrigNSURLSessionTask_resume)(id,SEL) = NULL;
NSURLSessionDataTask* (*gOrigDataTaskWithURLAndCompletionHandler)(id, SEL, NSURL*, DataTaskCompletionBlock) = NULL;
NSURLSessionDataTask* (*gOrigDataTaskWithRequestAndCompletionHandler)(id, SEL, NSURLRequest*, DataTaskCompletionBlock) = NULL;



static NSURLSession* NSURLSession_apigeeSessionWithConfigurationDelegateAndQueue(id self, SEL _cmd,NSURLSessionConfiguration* configuration,id delegate,NSOperationQueue* queue)
{
    NSURLSession* session = nil;
    
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
    uint64_t startTime = [ApigeeNetworkEntry machTime];
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    [monitoringClient setStartTime:startTime forSessionDataTask:self];
    
    // execute original implementation of 'resume' method
    gOrigNSCFLocalDataTask_resume(self,_cmd);
}

static void NSURLSessionTask_apigeeResume(id self, SEL _cmd)
{
    // set the starting time for this data task
    uint64_t startTime = [ApigeeNetworkEntry machTime];
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    [monitoringClient setStartTime:startTime forSessionDataTask:self];
    
    // execute original implementation of 'resume' method
    gOrigNSURLSessionTask_resume(self,_cmd);
}

static NSURLSessionDataTask* NSCFURLSession_apigeeDataTaskWithURLAndCompletionHandler(id self, SEL _cmd, NSURL* url, DataTaskCompletionBlock completionHandler)
{
    NSURLSessionDataTask* sessionDataTask = nil;
    
    if( completionHandler ) {
        ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
        id dataTaskIdentifier = [monitoringClient generateIdentifierForDataTask];
        
        // execute original implementation but with our own completion handler
        sessionDataTask =
        gOrigDataTaskWithURLAndCompletionHandler(self,_cmd,url,^(NSData *data,
                                                                 NSURLResponse *response,
                                                                 NSError *error) {
            
            uint64_t endTime = [ApigeeNetworkEntry machTime];
            
            ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
            [monitoringClient dataTaskInfoForIdentifier:dataTaskIdentifier];
            
            [sessionDataTaskInfo.networkEntry populateWithResponseData:data];
            [sessionDataTaskInfo.networkEntry populateWithResponse:response];
            [sessionDataTaskInfo.networkEntry populateWithError:error];
            [sessionDataTaskInfo.networkEntry populateStartTime:sessionDataTaskInfo.startTime
                                                          ended:endTime];
            
            [monitoringClient recordNetworkEntry:sessionDataTaskInfo.networkEntry];
            
            // do we have a completion handler?
            if( sessionDataTaskInfo.completionHandler ) {
                // run the completion handler
                sessionDataTaskInfo.completionHandler(data,response,error);
            }
            
            [monitoringClient removeDataTaskInfoForIdentifier:dataTaskIdentifier];
        });
        
        ApigeeNetworkEntry* networkEntry = [[ApigeeNetworkEntry alloc] init];
        [networkEntry populateWithURL:url];
        
        ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
        [[ApigeeNSURLSessionDataTaskInfo alloc] init];
        
        sessionDataTaskInfo.networkEntry = networkEntry;
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
    id dataTaskIdentifier = [monitoringClient generateIdentifierForDataTask];
    
    if( completionHandler ) {
        
        // execute original implementation with our own completion handler
        sessionDataTask =
        gOrigDataTaskWithRequestAndCompletionHandler(self,_cmd,request,^(NSData *data,
                                                                         NSURLResponse *response,
                                                                         NSError *error) {
            
            uint64_t endTime = [ApigeeNetworkEntry machTime];
            
            ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
            [monitoringClient dataTaskInfoForIdentifier:dataTaskIdentifier];
            
            
            [sessionDataTaskInfo.networkEntry populateWithResponseData:data];
            [sessionDataTaskInfo.networkEntry populateWithResponse:response];
            [sessionDataTaskInfo.networkEntry populateWithError:error];
            [sessionDataTaskInfo.networkEntry populateStartTime:sessionDataTaskInfo.startTime
                                                          ended:endTime];
            
            [monitoringClient recordNetworkEntry:sessionDataTaskInfo.networkEntry];
            
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
    
    ApigeeNetworkEntry* networkEntry = [[ApigeeNetworkEntry alloc] init];
    [networkEntry populateWithRequest:request];
    
    ApigeeNSURLSessionDataTaskInfo* sessionDataTaskInfo =
    [[ApigeeNSURLSessionDataTaskInfo alloc] init];
    
    sessionDataTaskInfo.networkEntry = networkEntry;
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
