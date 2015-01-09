//
//  Constants.m
//  oauth2
//
//  Created by Robert Walsh on 1/9/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "Constants.h"

/**
 * In order for this application sample application to function properly you will need to input your own credentials for the following
 * 8 constants below.  Failure to do so will result in unexpected/broken behavior.
 */
NSString* const kApigeeOrgID = @"<Your ORG ID>";
NSString* const kApigeeAppID = @"<Your APP ID or 'sandbox'>";
NSString* const kApigeePasswordGrantUsername = @"<The username for the user created on Baas>";
NSString* const kApigeePasswordGrantPassword = @"<The password for the user created on Baas>";
NSString* const kApigeeClientCredentialsClientID = @"<Your client id>";
NSString* const kApigeeClientCredentialsClientSecret = @"<Your client secret>";
NSString* const kFacebookClientID = @"<Your Facebook client id>";
NSString* const kFacebookClientSecret = @"<Your Facebook client secret>";

// Apigee Specific Constants
NSString* const kApigeeClientCredentialsGrantTokenURLFormat = @"https://%@-test.apigee.net/oauth/client_credential/accesstoken";
NSString* const kApigeeClientCredentialsWeatherInfoURLFormat = @"https://%@-test.apigee.net/v0/weather/forecastrss?w=12797282";
NSString* const kApigeePasswordGrantTokenURLFormat = @"https://api.usergrid.com/%@/%@/token";
NSString* const kApigeePasswordGrantUserInfoURLFormat = @"https://api.usergrid.com/%@/%@/users/%@";

// Facebook Specific Constants
NSString* const kFacebookServiceProviderName = @"Facebook";
NSString* const kFacebookKeychainItemName = @"OAuth2: Facebook";

NSString* const kFacebookAuthorizeURL = @"https://www.facebook.com/dialog/oauth?display=touch";
NSString* const kFacebookTokenURL = @"https://graph.facebook.com/oauth/access_token";
NSString* const kFacebookRedirectURL = @"http://blahblah.com/";
NSString* const kFacebookGetEmailURL = @"https://graph.facebook.com/me?fields=email";
NSString* const kFacebookPostOnWallURL = @"https://graph.facebook.com/me/feed?message=\"Hello, World.\"";

// Other Constants
NSString* const kNoTextDefault = @"N/A";
NSString* const kKeychainItemNameForManuallySaving = @"OAuth2 Example Keychain Store";
