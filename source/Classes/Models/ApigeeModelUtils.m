//
//  ApigeeModelUtils.m
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#include <objc/message.h>
#include <objc/runtime.h>

#import "ApigeeModelUtils.h"

@implementation ApigeeModelUtils

+ (NSDictionary *) asDictionary:(id) instance
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    unsigned int count = 0;
    Ivar *vars = class_copyIvarList([instance class], &count);
    
    for (int i = 0; i < count; i++) {
        Ivar var = vars[i];
        
        const char* varName = ivar_getName(var);
        
        NSString *name = [NSString stringWithUTF8String: varName];
        SEL selector = NSSelectorFromString(name);
        
        if ([instance respondsToSelector:selector]) {
            id value = objc_msgSend(instance, selector);
            [dictionary setValue:value forKey:name];
        }
    }
    
    free(vars);
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end
