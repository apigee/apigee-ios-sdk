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
 @abstract The ApigeeAPSDestination represents the intended destination
    for a push notification
 */
@interface ApigeeAPSDestination : NSObject

/*!
 @property deliveryPath The 'to' path for push notification delivery
 */
@property (strong, readonly) NSString* deliveryPath;

/*!
 @abstract Constructs a destination for all devices
 @return ApigeeAPSDestination instance
 */
+ (ApigeeAPSDestination*)destinationAllDevices;

/*!
 @abstract Constructs a destination for a single device
 @param deviceUUID The device identifier
 @return ApigeeAPSDestination instance
 */
+ (ApigeeAPSDestination*)destinationSingleDevice:(NSString*)deviceUUID;

/*!
 @abstract Constructs a destination for a list of devices
 @param listOfDeviceUUID The list of device identifiers
 @return ApigeeAPSDestination instance
 */
+ (ApigeeAPSDestination*)destinationMultipleDevices:(NSArray*)listOfDeviceUUID;

/*!
 @abstract Constructs a destination for a single user
 @param userName The user who should receive the notification
 @return ApigeeAPSDestination instance
 */
+ (ApigeeAPSDestination*)destinationSingleUser:(NSString*)userName;

/*!
 @abstract Constructs a destination for a list of users
 @param listOfUserNames The list of users who should receive the notification
 @return ApigeeAPSDestination instance
 */
+ (ApigeeAPSDestination*)destinationMultipleUsers:(NSArray*)listOfUserNames;

/*!
 @abstract Constructs a destination for a single group
 @param groupName The group who should receive the notification
 @return ApigeeAPSDestination instance
 */
+ (ApigeeAPSDestination*)destinationSingleGroup:(NSString*)groupName;

/*!
 @abstract Constructs a destination for a list of groups
 @param listOfGroupNames The list of groups who should receive the notification
 @return ApigeeAPSDestination instance
 */
+ (ApigeeAPSDestination*)destinationMultipleGroups:(NSArray*)listOfGroupNames;



@end
