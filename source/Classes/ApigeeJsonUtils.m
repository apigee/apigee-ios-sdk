//
//  ApigeeUtils.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeJsonUtils.h"
#import "ApigeeSBJsonWriter.h"
#import "ApigeeSBJsonParser.h"


@implementation ApigeeJsonUtils

+ (NSString*)encode:(id)object
{
    ApigeeSBJsonWriter* jsonWriter = [[ApigeeSBJsonWriter alloc] init];
    return [jsonWriter stringWithObject:object];
}

+ (id)decode:(NSString*)json
{
    NSError* error = nil;
    NSData* jsonAsData = [json dataUsingEncoding:NSUTF8StringEncoding];
    id objects = [NSJSONSerialization JSONObjectWithData:jsonAsData
                                                 options:NSJSONReadingMutableContainers
                                                   error:&error];
    if( objects == nil || error != nil ) {
        if( error != nil ) {
            NSLog( @"JSON parse error: %@", [error localizedDescription]);
        } else {
            NSLog( @"JSON parse failed. no error given");
        }
        
        return nil;
    } else {
        return objects;
    }
    
    /*
    ApigeeSBJsonParser* jsonParser = [[ApigeeSBJsonParser alloc] init];
    return [jsonParser objectWithData:json];
     */
}

@end
