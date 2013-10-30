//
//  ApigeeAPSDestination.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

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
