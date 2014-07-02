/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
