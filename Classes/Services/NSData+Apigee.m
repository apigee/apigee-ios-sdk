//
//  NSData+Apigee.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeNetworkEntry.h"
#import "NSData+Apigee.h"

@implementation NSData (Apigee)

+ (NSData*) timedDataWithContentsOfURL:(NSURL *) url options:(NSDataReadingOptions) readOptionsMask error:(NSError **) errorPtr
{
    NSDate *start = [NSDate date];
    NSData *data = [NSData dataWithContentsOfURL:url options:readOptionsMask error:errorPtr];
    NSDate *end = [NSDate date];
    
    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
    [entry populateWithURL:url];
    [entry populateStartTime:start ended:end];
    [entry populateWithResponseData:data];
    
    if (errorPtr && *errorPtr) {
        NSError *theError = *errorPtr;
        [entry populateWithError:theError];
    }
    
    [ApigeeQueue recordNetworkEntry:entry];
    
    return data;
}

+ (NSData*) timedDataWithContentsOfURL:(NSURL *) url
{
    NSDate *start = [NSDate date];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDate *end = [NSDate date];
    
    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
    [entry populateWithURL:url];
    [entry populateStartTime:start ended:end];
    [entry populateWithResponseData:data];
    
    [ApigeeQueue recordNetworkEntry:entry];
    
    return data;
}

- (id) initWithTimedContentsOfURL:(NSURL *) url options:(NSDataReadingOptions) readOptionsMask error:(NSError **) errorPtr
{
    NSDate *start = [NSDate date];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url options:readOptionsMask error:errorPtr];
    NSDate *end = [NSDate date];
    
    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
    [entry populateWithURL:url];
    [entry populateStartTime:start ended:end];
    [entry populateWithResponseData:data];
    
    if (errorPtr && *errorPtr) {
        NSError *theError = *errorPtr;
        [entry populateWithError:theError];
    }
    
    [ApigeeQueue recordNetworkEntry:entry];
    
    return data;
}

- (id) initWithTimedContentsOfURL:(NSURL *) url
{
    NSDate *start = [NSDate date];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    NSDate *end = [NSDate date];
    
    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
    [entry populateWithURL:url];
    [entry populateStartTime:start ended:end];
    [entry populateWithResponseData:data];
    
    [ApigeeQueue recordNetworkEntry:entry];
   
    return data;
}

- (BOOL) timedWriteToURL:(NSURL *)url atomically:(BOOL)atomically
{
    NSDate *start = [NSDate date];
    BOOL result = [self writeToURL:url atomically:atomically];
    NSDate *end = [NSDate date];
    
    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] init];
    [entry populateWithURL:url];
    [entry populateStartTime:start ended:end];
    
    [ApigeeQueue recordNetworkEntry:entry];
    
    return result;
}

- (BOOL) timedWriteToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
    NSDate *start = [NSDate date];
    BOOL result = [self writeToURL:url options:writeOptionsMask error:errorPtr];
    NSDate *end = [NSDate date];

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

    [ApigeeQueue recordNetworkEntry:entry];
    
    return result;
}

@end
