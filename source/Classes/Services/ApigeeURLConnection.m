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

#import "ApigeeNSURLConnectionDataDelegateInterceptor.h"
#import "ApigeeURLConnection.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeMonitoringClient.h"

@interface ApigeeURLConnection()

@property (strong) ApigeeNSURLConnectionDataDelegateInterceptor *interceptor;

@end

@implementation ApigeeURLConnection

+ (NSURLConnection *) connectionWithRequest:(NSURLRequest *) request delegate:(id < NSURLConnectionDelegate >) delegate
{
    return [[ApigeeURLConnection alloc] initWithRequest:request delegate:delegate];
}

+ (NSData *) sendSynchronousRequest:(NSURLRequest *) request
                       returningResponse:(NSURLResponse **)response
                                   error:(NSError **)error
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    
    NSError *reportingError = nil;
    NSData *responseData;
    
    if (error != nil) {
        responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:response
                                                                 error:error];
    } else {
        responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:response
                                                                 error:&reportingError];
    }
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [entry recordEndTime];
    
        [entry populateWithRequest:request];
    
        if (response && *response) {
            NSURLResponse *theResponse = *response;
            [entry populateWithResponse:theResponse];
        }
    
        if (responseData != nil) {
            [entry populateWithResponseData:responseData];
        } else {
            @try {
                if (error && *error) {
                    NSError *theError = *error;
                    [entry populateWithError:theError];
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
}

+ (void)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                               [entry recordEndTime];
                               
                               // invoke our caller's completion handler
                               if (handler) {
                                   handler(response,data,error);
                               }
                               
                               ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
                               if (![monitoringClient isPaused]) {
                                   [entry populateWithRequest:request];
                                   [entry populateWithResponse:response];
                                   [entry populateWithResponseData:data];
                               
                                   if (error) {
                                       [entry populateWithError:error];
                                   }
                               
                                   [monitoringClient recordNetworkEntry:entry];
                               } else {
                                   NSLog(@"Not capturing network metrics -- paused");
                               }
                            }];
}

- (id) initWithRequest:(NSURLRequest *)request
              delegate:(id < NSURLConnectionDelegate >)delegate
{
    self.interceptor =
        [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                      withRequest:request];
    return [super initWithRequest:request delegate:self.interceptor];
}

- (id) initWithRequest:(NSURLRequest *)request
              delegate:(id < NSURLConnectionDelegate >)delegate
      startImmediately:(BOOL)startImmediately
{
    self.interceptor =
        [[ApigeeNSURLConnectionDataDelegateInterceptor alloc] initAndInterceptFor:delegate
                                                                      withRequest:request];
    return [super initWithRequest:request
                         delegate:self.interceptor
                 startImmediately:startImmediately];
}

- (void) start
{
    [self.interceptor recordStartTime];
    
    [super start];
}

@end
