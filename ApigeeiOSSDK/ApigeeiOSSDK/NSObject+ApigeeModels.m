//
//  NSObject+ModelInitializer.m
//  InstaOpsAppMonitor
//
//  Created by jaminschubert on 9/14/12.
//  Copyright (c) 2012 InstaOps. All rights reserved.
//

#include <objc/runtime.h>
#import "NSObject+ApigeeModels.h"

@implementation NSObject (ApigeeModels)

- (void) initialzeWithEmptyStrings
{
    unsigned int count;
    
    Ivar *vars = class_copyIvarList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        if (![[NSString stringWithUTF8String:@encode(NSString *)] isEqualToString:[NSString stringWithUTF8String:ivar_getTypeEncoding(vars[i])]]) {
            continue;
        }
        
        NSString *name = [NSString stringWithUTF8String: ivar_getName(vars[i])];
        [self setValue:@"" forKey:name];
    }
    
    free(vars);
}
@end
