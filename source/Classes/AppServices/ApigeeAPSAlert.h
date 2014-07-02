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

/*!
 @abstract The ApigeeAPSAlert contains all the parameters that are supported
    by Apple for the 'alert' field of 'aps' when a dictionary of values is needed.
 See Table 3-2 at https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ApplePushService.html
 */
@interface ApigeeAPSAlert : NSObject

/*!
 @property body The 'body' field of 'alert' dictionary
 */
@property (strong) NSString* body;          // body

/*!
 @property actionLocKey The 'action-loc-key' field of 'alert' dictionary
 */
@property (strong) NSString* actionLocKey;  // action-loc-key

/*!
 @property locKey The 'loc-key' field of 'alert' dictionary
 */
@property (strong) NSString* locKey;        // loc-key

/*!
 @property locArgs The 'loc-args' field of 'alert' dictionary
 */
@property (strong) NSArray* locArgs;        // loc-args

/*!
 @property launchImage The 'launch-image' field of 'alert' dictionary
 */
@property (strong) NSString* launchImage;   // launch-image

/*!
 @abstract Retrieves the 'alert' fields as a dictionary
 @return the dictionary of 'alert' values
 */
- (NSDictionary*)toDictionary;

@end
