//
//  ApigeeAPSAlert.h
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

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
