//
//  NSString+Apigee.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeNetworkEntry.h"
#import "NSString+Apigee.h"
#import "ApigeeMonitoringClient.h"

@implementation NSString (Apigee)

+ (NSString*) stringWithTimedContentsOfURL:(NSURL *) url encoding:(NSStringEncoding) enc error:(NSError **) error
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    NSString *data = [NSString stringWithContentsOfURL:url encoding:enc error:error];
    [entry recordEndTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [entry populateWithURL:url];
    
        if (error && *error) {
            NSError *theError = *error;
            [entry populateWithError:theError];
        }
    
        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return data;
}

+ (NSString*) stringWithTimedContentsOfURL:(NSURL *) url usedEncoding:(NSStringEncoding *) enc error:(NSError **) error
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    NSString *data = [NSString stringWithContentsOfURL:url usedEncoding:enc error:error];
    [entry recordEndTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [entry populateWithURL:url];
    
        if (error && *error) {
            NSError *theError = *error;
            [entry populateWithError:theError];
        }
    
        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return data;
}

- (id) initWithTimedContentsOfURL:(NSURL *) url encoding:(NSStringEncoding) enc error:(NSError **) error
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    NSString *data = [[NSString alloc] initWithContentsOfURL:url encoding:enc error:error];
    [entry recordEndTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [entry populateWithURL:url];
    
        if (error && *error) {
            NSError *theError = *error;
            [entry populateWithError:theError];
        }
    
        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return data;
}

- (id) initWithTimedContentsOfURL:(NSURL *) url usedEncoding:(NSStringEncoding *) enc error:(NSError **) error
{
    ApigeeNetworkEntry* entry = [[ApigeeNetworkEntry alloc] init];
    [entry recordStartTime];
    NSString *data = [[NSString alloc] initWithContentsOfURL:url usedEncoding:enc error:error];
    [entry recordEndTime];

    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [entry populateWithURL:url];
    
        if (error && *error) {
            NSError *theError = *error;
            [entry populateWithError:theError];
        }
    
        [monitoringClient recordNetworkEntry:entry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    return data;
}

- (BOOL) containsString:(NSString *)substringToLookFor
{
    NSRange rangeSubstring = [self rangeOfString:substringToLookFor];
    return (rangeSubstring.location != NSNotFound);
}

@end
