//
//  ApigeeAPSPayload.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeAPSPayload.h"
#import "ApigeeAPSAlert.h"

@implementation ApigeeAPSPayload

@synthesize alertText;
@synthesize alertValues;
@synthesize badgeValue;
@synthesize sound;
@synthesize contentAvailable;

- (id)init
{
    self = [super init];
    if (self) {
        self.contentAvailable = NO;
    }
    
    return self;
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary* dictPayload = [[NSMutableDictionary alloc] init];
    
    if ([self.alertText length] > 0) {
        [dictPayload setValue:self.alertText
                       forKey:@"alert"];
    } else if (self.alertValues) {
        [dictPayload setValue:[self.alertValues toDictionary]
                       forKey:@"alert"];
    }
    
    if (self.badgeValue) {
        int badgeValueInt = [self.badgeValue intValue];
        if (badgeValueInt >= 0) {
            [dictPayload setValue:self.badgeValue
                           forKey:@"badge"];
        }
    }
    
    if ([self.sound length] > 0) {
        [dictPayload setValue:self.sound
                       forKey:@"sound"];
    }
    
    if (self.contentAvailable) {
        [dictPayload setValue:[NSNumber numberWithInt:1]
                       forKey:@"content-available"];
    }
    
    return dictPayload;
}

@end
