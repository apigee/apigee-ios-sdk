//
//  Constants.h
//  oauth2
//
//  Created by Robert Walsh on 1/9/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * In order for this application sample application to function properly you will need to input your own credentials for the following
 * 8 constants below.  Failure to do so will result in unexpected/broken behavior.
 */
extern NSString* const kApigeeOrgID;
extern NSString* const kApigeeAppID;
extern NSString* const kApigeePasswordGrantUsername;
extern NSString* const kApigeePasswordGrantPassword;
extern NSString* const kApigeeClientCredentialsClientID;
extern NSString* const kApigeeClientCredentialsClientSecret;
extern NSString* const kFacebookClientID;
extern NSString* const kFacebookClientSecret;

// Apigee Specific Constants
extern NSString* const kApigeeClientCredentialsGrantTokenURLFormat;
extern NSString* const kApigeeClientCredentialsWeatherInfoURLFormat;
extern NSString* const kApigeePasswordGrantTokenURLFormat;
extern NSString* const kApigeePasswordGrantUserInfoURLFormat;

// Facebook Specific Constants
extern NSString* const kFacebookServiceProviderName;
extern NSString* const kFacebookKeychainItemName;

extern NSString* const kFacebookAuthorizeURL;
extern NSString* const kFacebookTokenURL;
extern NSString* const kFacebookRedirectURL;
extern NSString* const kFacebookGetEmailURL;
extern NSString* const kFacebookPostOnWallURL;

// Other Constants
extern NSString* const kNoTextDefault;
extern NSString* const kKeychainItemNameForManuallySaving;
