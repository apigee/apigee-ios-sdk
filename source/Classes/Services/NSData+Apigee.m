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

#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeNetworkEntry.h"
#import "NSData+Apigee.h"
#import "ApigeeMonitoringClient.h"

@implementation NSData (Apigee)

+ (NSData*) timedDataWithContentsOfURL:(NSURL *) url options:(NSDataReadingOptions) readOptionsMask error:(NSError **) errorPtr
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    NSData *data = [NSData dataWithContentsOfURL:url options:readOptionsMask error:errorPtr];
    [entry recordEndTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [entry populateWithURL:url];
        [entry populateWithResponseData:data];
    
        if (errorPtr && *errorPtr) {
            NSError *theError = *errorPtr;
            [entry populateWithError:theError];
        }
    
        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return data;
}

+ (NSData*) timedDataWithContentsOfURL:(NSURL *) url
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    NSData *data = [NSData dataWithContentsOfURL:url];
    [entry recordEndTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [entry populateWithURL:url];
        [entry populateWithResponseData:data];
    
        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return data;
}

- (id) initWithTimedContentsOfURL:(NSURL *) url options:(NSDataReadingOptions) readOptionsMask error:(NSError **) errorPtr
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url options:readOptionsMask error:errorPtr];
    [entry recordEndTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [entry populateWithURL:url];
        [entry populateWithResponseData:data];
    
        if (errorPtr && *errorPtr) {
            NSError *theError = *errorPtr;
            [entry populateWithError:theError];
        }
    
        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return data;
}

- (id) initWithTimedContentsOfURL:(NSURL *) url
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    [entry recordEndTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [entry populateWithURL:url];
        [entry populateWithResponseData:data];
    
        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return data;
}

- (BOOL) timedWriteToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    BOOL result = [self writeToURL:url options:writeOptionsMask error:errorPtr];
    [entry recordEndTime];

    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [entry populateWithURL:url];
    
        if (!result) {
            entry.numErrors = @"1";
            if (errorPtr && *errorPtr) {
                NSError *theError = *errorPtr;
                [entry populateWithError:theError];
            }
        }

        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return result;
}

@end
