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

#import "ApigeeJSONConfigKeys.h"
#import "ApigeeCustomConfigParam+JSON.h"

@implementation ApigeeCustomConfigParam (JSON)

+ (NSArray *) transformArray:(NSArray *) jsonObjects
{
    if (!jsonObjects) {
        return nil;
    }
    
    NSMutableArray *params = [NSMutableArray array];
    
    for (NSDictionary *obj in jsonObjects) {
        [params addObject:[self fromDictionary:obj]];
    }
    
    return params;
}

+ (ApigeeCustomConfigParam *) fromDictionary:(NSDictionary *) jsonObjects
{
    if (!jsonObjects) {
        return nil;
    }
    
    ApigeeCustomConfigParam *param = [[ApigeeCustomConfigParam alloc] init];
    
    param.paramId = [[jsonObjects objectForKey:kAppConfigCustomParamId]integerValue];
    param.category = [jsonObjects objectForKey:kAppConfigCustomParamTag];
    param.key = [jsonObjects objectForKey:kAppConfigCustomParamKey];
    param.value = [jsonObjects objectForKey:kAppConfigCustomParamValue];
    
    return param;
}

@end
