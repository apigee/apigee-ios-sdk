//
//  NSString+UUID.m
//  InstaOpsAppMonitor
//
//  Created by jaminschubert on 10/13/12.
//  Copyright (c) 2012 InstaOps. All rights reserved.
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
