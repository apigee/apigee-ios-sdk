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

@class ApigeeAPSAlert;

/*!
 @abstract The ApigeeAPSAlert contains all of the parameters that are supported
    by Apple for the 'aps' payload of a push notification.
 @discussion Note that only one of 'alertText' and 'alertValues' should be
    set. See Table 3-1 at https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ApplePushService.html
 */
@interface ApigeeAPSPayload : NSObject

/*!
 @property alertText The 'alert' field (as a string) of 'aps'
 */
@property (strong) NSString* alertText;             // alert (string)

/*!
 @property alertValues The 'alert' field (as a dictionary) of 'aps'
 */
@property (strong) ApigeeAPSAlert* alertValues;     // alert (dictionary)

/*!
 @property badgeValue The 'badge' field of 'aps'
 */
@property (strong) NSNumber* badgeValue;            // badge

/*!
 @property sound The 'sound' field of 'aps'
 */
@property (strong) NSString* sound;                 // sound

/*!
 @property contentAvailable The 'content-available' property of 'aps'
 */
@property (assign) BOOL contentAvailable;           // content-available

/*!
 @abstract Retrieves the APS payload as a dictionary
 @return the dictionary of APS payload values
 */
- (NSDictionary*)toDictionary;

@end
