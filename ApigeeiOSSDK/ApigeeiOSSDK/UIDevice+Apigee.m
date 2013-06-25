//
//  UIDevice+Apigee.m
//  ApigeeAppMonitor
//
//  Created by Paul Dardeau on 11/19/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "UIDevice+Apigee.h"

#include <sys/types.h>
#include <sys/sysctl.h>

static const char *kHardwareMachineType = "hw.machine";


@implementation UIDevice (Apigee)

+ (NSString *) platformStringRaw
{
    size_t size;
    sysctlbyname(kHardwareMachineType, NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname(kHardwareMachineType, machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *) platformStringDescriptive
{
    NSString *platform = [self platformStringRaw];
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone (Original/2G)";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone1,2*"])   return @"iPhone 3G (China/No WiFi)";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone2,1*"])   return @"iPhone 3GS (China/No WiFi)";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM/LTE)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (CDMA/LTE)";

    // iPod Touch
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    
    // iPad
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad mini";

    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad-3G (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad-3G (4G)";

    // Simulator
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    // We don't know yet
    return platform;
}

@end
