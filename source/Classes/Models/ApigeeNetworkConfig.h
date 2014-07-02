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

#import <Foundation/Foundation.h>


@interface ApigeeNetworkConfig : NSObject

@property (assign, nonatomic) NSInteger configId;
@property (assign, nonatomic) BOOL heuristicCachingEnabled;
@property (assign, nonatomic) float heuristicCoefficient;
@property (assign, nonatomic) NSInteger heuristicDefaultLifetime;
@property (assign, nonatomic) BOOL isSharedCache;
@property (assign, nonatomic) NSInteger maxCacheEntries;
@property (assign, nonatomic) NSInteger maxObjectSizeBytes;
@property (assign, nonatomic) NSInteger maxUpdateRetries;

@end
