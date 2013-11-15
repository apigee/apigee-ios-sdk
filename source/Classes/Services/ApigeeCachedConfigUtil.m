//
//  ApigeeCachedConfigUtil.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeCompositeConfiguration.h"
#import "ApigeeCompositeConfiguration+JSON.h"
#import "ApigeeCompositeConfiguration+Initializers.h"
#import "ApigeeCachedConfigUtil.h"
#import "ApigeeJsonUtils.h"
#import "ApigeeMonitoringClient.h"

static NSString* kApigeeDisckCacheErrorDomain = @"apigee-disk-cache";
static NSString* kApigeeConfigFileName = @"config.json";

@interface ApigeeCachedConfigUtil ()

+ (NSString *) myCacheDirectory;
+ (NSString *) configFilePath;

@end

@implementation ApigeeCachedConfigUtil

+ (NSString*)configFileName
{
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    return [NSString stringWithFormat:@"%@_%@",
            [monitoringClient uniqueIdentifierForApp],
            kApigeeConfigFileName];
}

#pragma mark - Private implementations

+ (NSString *) myCacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *) configFilePath
{
    return [[self myCacheDirectory] stringByAppendingPathComponent:[self configFileName]];
}

+ (BOOL) isCached
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self configFilePath]];
}

#pragma mark - Public implementations

+ (ApigeeCompositeConfiguration *) parseConfiguration:(NSString*)jsonConfigAsString
                                                error:(NSError**)error
{
    id objects = [ApigeeJsonUtils decode:jsonConfigAsString error:error];
    
    if( (objects == nil) || *error ) {
        NSLog(@"JSON serialization returned nil");
        return nil;
    }
    
    return [ApigeeCompositeConfiguration fromDictionary:objects];
}

/**
 * note: we must always return a configuration, even if there is no available entry in the cache
 */
+ (ApigeeCompositeConfiguration *) getConfiguration:(NSError **) error
{
    if (![self isCached]) {
        return [ApigeeCompositeConfiguration defaultConfiguration];
    }
    
    NSData* contents = [[NSFileManager defaultManager] contentsAtPath:[self configFilePath]];
    
    if (!contents) {
        if (*error) {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Error fetching config file contents from disk"
                           forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:kApigeeDisckCacheErrorDomain
                                         code:kApigeeGetConfiguationFailed
                                     userInfo:errorDetail];
        }
        
        return nil;
    }
    
    NSString* contentsAsString = [[NSString alloc] initWithData:contents
                                                       encoding:NSUTF8StringEncoding];
    return [self parseConfiguration:contentsAsString error:error];
}

+ (BOOL) updateConfiguration:(NSData *) fileData error:(NSError **) error
{
    if ([[NSFileManager defaultManager] createFileAtPath:[self configFilePath]
                                                contents:fileData
                                              attributes:nil]) {
        return YES;
    }
    
    if (*error) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Error updating cache file on disk"
                       forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:kApigeeDisckCacheErrorDomain
                                     code:kApigeeUpdateConfiguationFailed
                                 userInfo:errorDetail];
    }
    
    return NO;
}

@end
