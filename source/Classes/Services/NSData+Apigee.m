//
//  NSData+Apigee.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeNetworkEntry.h"
#import "NSData+Apigee.h"
#import "ApigeeMonitoringClient.h"

@implementation NSData (Apigee)

+ (NSData*) timedDataWithContentsOfURL:(NSURL *) url options:(NSDataReadingOptions) readOptionsMask error:(NSError **) errorPtr
{
    uint64_t start = [ApigeeNetworkEntry machTime];
    NSData *data = [NSData dataWithContentsOfURL:url options:readOptionsMask error:errorPtr];
    uint64_t end = [ApigeeNetworkEntry machTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURL:url];
        [entry populateStartTime:start ended:end];
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
    uint64_t start = [ApigeeNetworkEntry machTime];
    NSData *data = [NSData dataWithContentsOfURL:url];
    uint64_t end = [ApigeeNetworkEntry machTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURL:url];
        [entry populateStartTime:start ended:end];
        [entry populateWithResponseData:data];
    
        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return data;
}

- (id) initWithTimedContentsOfURL:(NSURL *) url options:(NSDataReadingOptions) readOptionsMask error:(NSError **) errorPtr
{
    uint64_t start = [ApigeeNetworkEntry machTime];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url options:readOptionsMask error:errorPtr];
    uint64_t end = [ApigeeNetworkEntry machTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURL:url];
        [entry populateStartTime:start ended:end];
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
    uint64_t start = [ApigeeNetworkEntry machTime];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    uint64_t end = [ApigeeNetworkEntry machTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURL:url];
        [entry populateStartTime:start ended:end];
        [entry populateWithResponseData:data];
    
        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return data;
}

- (BOOL) timedWriteToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
    uint64_t start = [ApigeeNetworkEntry machTime];
    BOOL result = [self writeToURL:url options:writeOptionsMask error:errorPtr];
    uint64_t end = [ApigeeNetworkEntry machTime];

    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURL:url];
        [entry populateStartTime:start ended:end];
    
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
