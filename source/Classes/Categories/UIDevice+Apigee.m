//
//  UIDevice+Apigee.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "UIDevice+Apigee.h"

#include <sys/types.h>
#include <sys/sysctl.h>

static const char *kHardwareMachineType = "hw.machine";


@implementation UIDevice (Apigee)

+ (BOOL) apigeeIs64Bit
{
    void* aPointer = NULL;
    if( sizeof(aPointer) >= 64 ) {
        return YES;
    }
    
    return NO;
    
    /*
    int error = 0;
    int value = 0;
    size_t length = sizeof(value);
    
    error = sysctlbyname("hw.cpu64bit_capable", &value, &length, NULL, 0);
    
    if(error != 0) {
        error = sysctlbyname("hw.optional.x86_64", &value, &length, NULL, 0); //x86 specific
    }
    
    if(error != 0) {
        error = sysctlbyname("hw.optional.64bitops", &value, &length, NULL, 0); //PPC specific
    }
    
    BOOL is64bit = NO;
    
    if (error == 0) {
        is64bit = value == 1;
    }
    
    return is64bit;
     */
}

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

    //TODO: add identifiers for iPhone5s (and iPhone5c, if it has one)

    // iPhone
    if ([platform hasPrefix:@"iPhone"]) {
        if ([platform isEqualToString:@"iPhone1,1"]) {
            platform = @"iPhone (Original/2G)";
        } else if ([platform isEqualToString:@"iPhone1,2"]) {
            platform = @"iPhone 3G";
        } else if ([platform isEqualToString:@"iPhone1,2*"]) {
            platform = @"iPhone 3G (China/No WiFi)";
        } else if ([platform isEqualToString:@"iPhone2,1"]) {
            platform = @"iPhone 3GS";
        } else if ([platform isEqualToString:@"iPhone2,1*"]) {
            platform = @"iPhone 3GS (China/No WiFi)";
        } else if ([platform isEqualToString:@"iPhone3,1"]) {
            platform = @"iPhone 4 (GSM)";
        } else if ([platform isEqualToString:@"iPhone3,3"]) {
            platform = @"iPhone 4 (CDMA)";
        } else if ([platform isEqualToString:@"iPhone4,1"]) {
            platform = @"iPhone 4S";
        } else if ([platform isEqualToString:@"iPhone5,1"]) {
            platform = @"iPhone 5 (GSM/LTE)";
        } else if ([platform isEqualToString:@"iPhone5,2"]) {
            platform = @"iPhone 5 (CDMA/LTE)";
        }
    } else if ([platform hasPrefix:@"iPod"]) {
        if ([platform isEqualToString:@"iPod1,1"]) {
            platform = @"iPod Touch 1G";
        } else if ([platform isEqualToString:@"iPod2,1"]) {
            platform = @"iPod Touch 2G";
        } else if ([platform isEqualToString:@"iPod3,1"]) {
            platform = @"iPod Touch 3G";
        } else if ([platform isEqualToString:@"iPod4,1"]) {
            platform = @"iPod Touch 4G";
        }
    } else if ([platform hasPrefix:@"iPad"]) {
        if ([platform isEqualToString:@"iPad1,1"]) {
            platform = @"iPad";
        } else if ([platform isEqualToString:@"iPad2,1"]) {
            platform = @"iPad 2 (WiFi)";
        } else if ([platform isEqualToString:@"iPad2,2"]) {
            platform = @"iPad 2 (GSM)";
        } else if ([platform isEqualToString:@"iPad2,3"]) {
            platform = @"iPad 2 (CDMA)";
        } else if ([platform isEqualToString:@"iPad2,4"]) {
            platform = @"iPad 2";
        } else if ([platform isEqualToString:@"iPad2,5"]) {
            platform = @"iPad mini";
        } else if ([platform isEqualToString:@"iPad3,1"]) {
            platform = @"iPad-3G (WiFi)";
        } else if ([platform isEqualToString:@"iPad3,2"]) {
            platform = @"iPad-3G (4G)";
        } else if ([platform isEqualToString:@"iPad3,3"]) {
            platform = @"iPad-3G (4G)";
        }
    } else {
        // Simulator
        if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"]) {
            platform = @"Simulator";
        }
    }
    
    if ([UIDevice apigeeIs64Bit]) {
        platform = [NSString stringWithFormat:@"%@ (64-bit)", platform];
    }
    
    // We don't know yet
    return platform;
}

@end
