//
//  ApigeeAPSPayload.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

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
