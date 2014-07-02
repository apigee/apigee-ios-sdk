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
#import "ApigeeConfigFilter+JSON.h"

@implementation ApigeeConfigFilter (JSON)

+ (NSArray *) transformArray:(NSArray *) jsonObjects
{
    if (!jsonObjects || [jsonObjects isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray array];

    for (NSDictionary *obj in jsonObjects) {
        [array addObject:[self fromDictionary:obj]];
    }

    return array;
}

+ (ApigeeConfigFilter *) fromDictionary:(NSDictionary *) jsonObjects
{
    if (!jsonObjects || [jsonObjects isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    ApigeeConfigFilter *filter = [[ApigeeConfigFilter alloc] init];

    filter.filterId = [[jsonObjects objectForKey:kAppConfigFilterId] integerValue];
    filter.filterType = [jsonObjects objectForKey:kAppConfigFilterType];
    filter.filterValue = [jsonObjects objectForKey:kAppConfigFilterValue];
    
    return filter;
}

@end
