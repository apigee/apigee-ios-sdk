//
//  NSString+UUID.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *) uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    return [NSString stringWithString:(__bridge_transfer NSString *) uuidStringRef];
}

@end
