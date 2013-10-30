//
//  ApigeeAPSAlert.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeAPSAlert.h"

@implementation ApigeeAPSAlert

@synthesize body;
@synthesize actionLocKey;
@synthesize locKey;
@synthesize locArgs;
@synthesize launchImage;

- (void)setValue:(id)value forKey:(NSString*)key into:(NSMutableDictionary*)dict
{
    if (value) {
        [dict setValue:value forKey:key];
    } else {
        [dict setValue:[NSNull null] forKey:key];
    }
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary* dictAlert = [[NSMutableDictionary alloc] init];
    
    [self setValue:self.body forKey:@"body" into:dictAlert];
    [self setValue:self.actionLocKey forKey:@"action-loc-key" into:dictAlert];
    [self setValue:self.locKey forKey:@"loc-key" into:dictAlert];
    [self setValue:self.locArgs forKey:@"loc-args" into:dictAlert];
    [self setValue:self.launchImage forKey:@"launch-image" into:dictAlert];
    
    return dictAlert;
}

@end
