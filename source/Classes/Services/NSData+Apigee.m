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
