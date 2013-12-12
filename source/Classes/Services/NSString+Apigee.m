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
    uint64_t start = [ApigeeNetworkEntry machTime];
    NSString *data = [NSString stringWithContentsOfURL:url encoding:enc error:error];
    uint64_t end = [ApigeeNetworkEntry machTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURL:url];
        [entry populateStartTime:start ended:end];
    
        if (error && *error) {
            NSError *theError = *error;
            [entry populateWithError:theError];
        }
    
        [monitoringClient recordNetworkEntry:entry];
    }
    
    return data;
}

+ (NSString*) stringWithTimedContentsOfURL:(NSURL *) url usedEncoding:(NSStringEncoding *) enc error:(NSError **) error
{
    uint64_t start = [ApigeeNetworkEntry machTime];
    NSString *data = [NSString stringWithContentsOfURL:url usedEncoding:enc error:error];
    uint64_t end = [ApigeeNetworkEntry machTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURL:url];
        [entry populateStartTime:start ended:end];
    
        if (error && *error) {
            NSError *theError = *error;
            [entry populateWithError:theError];
        }
    
        [monitoringClient recordNetworkEntry:entry];
    }
    
    return data;
}

- (id) initWithTimedContentsOfURL:(NSURL *) url encoding:(NSStringEncoding) enc error:(NSError **) error
{
    uint64_t start = [ApigeeNetworkEntry machTime];
    NSString *data = [[NSString alloc] initWithContentsOfURL:url encoding:enc error:error];
    uint64_t end = [ApigeeNetworkEntry machTime];
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURL:url];
        [entry populateStartTime:start ended:end];
    
        if (error && *error) {
            NSError *theError = *error;
            [entry populateWithError:theError];
        }
    
        [monitoringClient recordNetworkEntry:entry];
    }
    
    return data;
}

- (id) initWithTimedContentsOfURL:(NSURL *) url usedEncoding:(NSStringEncoding *) enc error:(NSError **) error
{
    uint64_t start = [ApigeeNetworkEntry machTime];
    NSString *data = [[NSString alloc] initWithContentsOfURL:url usedEncoding:enc error:error];
    uint64_t end = [ApigeeNetworkEntry machTime];

    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
        [entry populateWithURL:url];
        [entry populateStartTime:start ended:end];
    
        if (error && *error) {
            NSError *theError = *error;
            [entry populateWithError:theError];
        }
    
        [monitoringClient recordNetworkEntry:entry];
    }
    
    return data;
}

- (BOOL) containsString:(NSString *)substringToLookFor
{
    NSRange rangeSubstring = [self rangeOfString:substringToLookFor];
    return (rangeSubstring.location != NSNotFound);
}

@end
