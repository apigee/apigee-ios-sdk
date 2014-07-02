/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
}

+ (NSString *) platformStringRaw
{
    NSString* platform = nil;
    size_t size;
    sysctlbyname(kHardwareMachineType, NULL, &size, NULL, 0);
    
    if (size > 0) {
        char *machine = malloc(size);
        sysctlbyname(kHardwareMachineType, machine, &size, NULL, 0);
        platform = [NSString stringWithUTF8String:machine];
        free(machine);
    }
    
    return platform;
}

+ (NSString *) platformStringDescriptive
{
    NSString *platform = [self platformStringRaw];

    // see the following web page for detailed information on the various
    // hardware models: http://theiphonewiki.com/wiki/Models

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
        } else if ([platform isEqualToString:@"iPhone5,3"]) {
            platform = @"iPhone 5c (GSM)";
        } else if ([platform isEqualToString:@"iPhone5,4"]) {
            platform = @"iPhone 5c (Global)";
        } else if ([platform isEqualToString:@"iPhone6,1"]) {
            platform = @"iPhone 5s (GSM)";
        } else if ([platform isEqualToString:@"iPhone6,2"]) {
            platform = @"iPhone 5s (Global)";
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
        } else if ([platform isEqualToString:@"iPod5,1"]) {
            platform = @"iPod Touch 5G";
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
        } else if ([platform isEqualToString:@"iPad4,1"]) {
            platform = @"iPad Air (WiFi)";
        } else if ([platform isEqualToString:@"iPad4,2"]) {
            platform = @"iPad Air (Cellular)";
        } else if ([platform isEqualToString:@"iPad4,4"]) {
            platform = @"iPad mini 2G (WiFi)";
        } else if ([platform isEqualToString:@"iPad4,5"]) {
            platform = @"iPad mini 2G (Cellular)";
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
