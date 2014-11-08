//
//  ViewController.m
//  oauth2
//
//  Created by Robert Walsh on 10/21/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "ViewController.h"

#import "ApigeeiOSSDK/Apigee.h"

#import "ImplicitOAuth2ViewController.h"

static NSString* const kNoTextDefault = @"N/A";
static NSString* const kKeychainItemNameForManuallySaving = @"OAuth2 Example Keychain Store";

// Apigee Specific Constants
static NSString* const kApigeeOrgID = @"rwalsh";
static NSString* const kApigeeAppID = @"sdk.demo";

static NSString* const kApigeeClientCredentialsClientID = @"lwjcjHK78Dl9eqqICFqYMZGqvxvGP2Uq";
static NSString* const kApigeeClientCredentialsClientSecret = @"VnEjVv6aANiGFUct";
static NSString* const kApigeeClientCredentialsGrantTokenURLFormat = @"https://%@-test.apigee.net/oauth/client_credential/accesstoken";
static NSString* const kApigeeClientCredentialsWeatherInfoURLFormat = @"https://%@-test.apigee.net/v0/weather/forecastrss?w=12797282";

static NSString* const kApigeePasswordGrantUsername = @"OAuthTestUser";
static NSString* const kApigeePasswordGrantPassword = @"Password1";
static NSString* const kApigeePasswordGrantTokenURLFormat = @"https://api.usergrid.com/%@/%@/token";
static NSString* const kApigeePasswordGrantUserInfoURLFormat = @"https://api.usergrid.com/%@/%@/users/%@";

// Facebook Specific Constants
static NSString* const kFacebookServiceProviderName = @"Facebook";
static NSString* const kFacebookKeychainItemName = @"OAuth2: Facebook";
static NSString* const kFacebookClientID = @"199268823468140";
static NSString* const kFacebookClientSecret = @"5437288538aa70ac5032d7ab7987e866";

static NSString* const kFacebookAuthorizeURL = @"https://www.facebook.com/dialog/oauth?display=touch";
static NSString* const kFacebookTokenURL = @"https://graph.facebook.com/oauth/access_token";
static NSString* const kFacebookRedirectURL = @"http://blahblah.com/";
static NSString* const kFacebookGetEmailURL = @"https://graph.facebook.com/me?fields=email";
static NSString* const kFacebookPostOnWallURL = @"https://graph.facebook.com/me/feed?message=\"Hello, World.\"";

@interface ViewController ()

@property (strong, nonatomic) ApigeeClient* client;

@property (copy,nonatomic) NSString* accessToken;
@property (copy,nonatomic) NSString* refreshToken;

@property (weak, nonatomic) IBOutlet UILabel *accessTokenLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    _client = [[ApigeeClient alloc] initWithOrganizationId:kApigeeOrgID applicationId:kApigeeAppID];
}

-(IBAction)clearTokenAndEmail:(id)sender
{
    [self resetTokensAndEmail];
}

-(void)resetTokensAndEmail
{
    [self setAccessToken:nil];
    [self setRefreshToken:nil];

    [[self tempLabel] setText:kNoTextDefault];
    [[self accessTokenLabel] setText:kNoTextDefault];
    [[self emailLabel] setText:kNoTextDefault];
}

-(void)showAlertWithTitle:(NSString*)title
                  message:(NSString*)message
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Apigee: grant_type=client_credentials

- (IBAction)grabAccessTokenUsingClientCredentialsGrantType:(id)sender {

    [self resetTokensAndEmail];

    [[[self client] dataClient] accessTokenWithURL:[NSString stringWithFormat:kApigeeClientCredentialsGrantTokenURLFormat,kApigeeOrgID]
                                          clientID:kApigeeClientCredentialsClientID
                                      clientSecret:kApigeeClientCredentialsClientSecret
                                 completionHandler:^(NSString *accessToken, NSString *refreshToken, NSError *error) {
                                     if( error == nil && [accessToken length] > 0 ) {
                                         [self setAccessToken:accessToken];
                                         [self setRefreshToken:refreshToken];
                                         [[self accessTokenLabel] setText:accessToken];
                                     } else {
                                         [self showAlertWithTitle:@"Error using client_credentials grant type." message:[error description]];
                                     }
                                 }];
}

#pragma mark Apigee: grant_type=password

-(IBAction)grabAccessTokenUsingPasswordGrantType:(id)sender
{
    [self resetTokensAndEmail];

    [[[self client] dataClient] accessTokenWithURL:[NSString stringWithFormat:kApigeePasswordGrantTokenURLFormat,kApigeeOrgID,kApigeeAppID]
                                          username:kApigeePasswordGrantUsername
                                          password:kApigeePasswordGrantPassword
                                          clientID:nil
                                 completionHandler:^(NSString *accessToken, NSString *refreshToken, NSError *error) {
                                     if( error == nil && [accessToken length] > 0 ) {
                                         [self setAccessToken:accessToken];
                                         [self setRefreshToken:refreshToken];
                                         [[self accessTokenLabel] setText:accessToken];
                                     } else {
                                         [self showAlertWithTitle:@"Error using password grant type." message:[error description]];
                                     }
                                 }];
}

#pragma mark Facebook: grant_type=implicit

-(IBAction)grabAccessTokenUsingImplicitGrantType:(id)sender {

    [self resetTokensAndEmail];

    NSMutableString* implicitGrantURL = [NSMutableString stringWithString:kFacebookAuthorizeURL];
    [implicitGrantURL appendFormat:@"&response_type=%@&client_id=%@&redirect_uri=%@",@"token",kFacebookClientID,kFacebookRedirectURL];

    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:implicitGrantURL]];

    ImplicitOAuth2ViewController* viewController = [[ImplicitOAuth2ViewController alloc] initWithOAuthRequest:urlRequest
                                                                                                  redirectURI:kFacebookRedirectURL
                                                                                            completionHandler:^(NSString *accessToken) {

                                                                                                [[self navigationController] popViewControllerAnimated:YES];

                                                                                                if( [accessToken length] > 0 ) {
                                                                                                    [self setAccessToken:accessToken];
                                                                                                    [[self accessTokenLabel] setText:accessToken];
                                                                                                }
                                                                                            }];

    [[self navigationController] pushViewController:viewController animated:YES];
}


#pragma mark Facebook: grant_type=authorization_code

-(IBAction)grabAccessTokenUsingAuthorizationCodeGrantType:(id)sender {

    [self resetTokensAndEmail];

    [[_client dataClient] authorizeOAuth2:kFacebookServiceProviderName
                             authorizeURL:kFacebookAuthorizeURL
                                 tokenURL:kFacebookTokenURL
                              redirectURL:kFacebookRedirectURL
                                 clientID:kFacebookClientID
                             clientSecret:kFacebookClientSecret
                                    scope:nil
                         keyChainItemName:kFacebookKeychainItemName
                     navigationController:[self navigationController]
                        completionHandler:^(NSString *accessToken, NSString *refreshToken, NSError *error) {

                            [[self navigationController] dismissViewControllerAnimated:YES
                                                                            completion:nil];
                            if( error == nil && [accessToken length] > 0 ) {
                                [self setAccessToken:accessToken];
                                [self setRefreshToken:refreshToken];
                                [[self accessTokenLabel] setText:accessToken];
                            } else if( error != nil ) {
                                [self showAlertWithTitle:@"Error using authorization_code grant type." message:[error description]];
                            }
                        }];
}

#pragma mark Apigee: Get Weather Info

-(IBAction)getApigeePaloAltoTemp:(id)sender {

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kApigeeClientCredentialsWeatherInfoURLFormat,kApigeeOrgID]]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",self.accessToken] forHTTPHeaderField:@"Authorization"];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                               NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

                               if( [responseDictionary valueForKeyPath:@"rss.channel.item.yweather:condition.#attrs"] != nil )
                               {
                                   NSDictionary* tempAttributes = [responseDictionary valueForKeyPath:@"rss.channel.item.yweather:condition.#attrs"];
                                   NSString* tempString = [tempAttributes objectForKey:@"@temp"];

                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [[self tempLabel] setText:[NSString stringWithFormat:@"%@%@",tempString,@"\u00B0"]];
                                   });
                               }
                               else
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlertWithTitle:@"Error getting Apigee Palo Alto Temp." message:@"Unable to authenticate OAuth credentials"];
                                   });
                               }
                           }];
}

#pragma mark Apigee: Get Email

-(IBAction)getApigeeEmail:(id)sender {

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kApigeePasswordGrantUserInfoURLFormat,kApigeeOrgID,kApigeeAppID,kApigeePasswordGrantUsername]]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",self.accessToken] forHTTPHeaderField:@"Authorization"];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                               NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

                               if( responseDictionary[@"entities"] != nil )
                               {
                                   NSArray* entitiesArray = responseDictionary[@"entities"];
                                   NSDictionary* userEntityInfo = [entitiesArray firstObject];
                                   if( [userEntityInfo isKindOfClass:[NSDictionary class]] ) {
                                       NSString* userEmail = userEntityInfo[@"email"];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[self emailLabel] setText:userEmail];
                                       });
                                   }
                               }
                               else if( responseDictionary[@"error_description"] != nil )
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlertWithTitle:@"Error getting Apigee user email." message:responseDictionary[@"error_description"]];
                                   });
                               }
                           }];
}

#pragma mark Facebook: Get email

-(IBAction)getFacebookEmail:(id)sender {

    if( [self.accessToken length] <= 0 ) {
        [self showAlertWithTitle:@"Error getting Facebook Email" message:@"No access token available."];
    } else {

        NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[self getFacebookURLByAddingAccessToken:kFacebookGetEmailURL]];
        [urlRequest setHTTPMethod:@"GET"];

        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                                   NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

                                   if( responseDictionary[@"email"] != nil )
                                   {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[self emailLabel] setText:responseDictionary[@"email"]];
                                       });
                                   }
                                   else
                                   {
                                       // Show the error message if we can.
                                       if( responseDictionary[@"error"] ) {
                                           NSDictionary* responseErrorDict = responseDictionary[@"error"];
                                           if( [responseErrorDict isKindOfClass:[NSDictionary class]] && responseErrorDict[@"message"] != nil ) {
                                               NSString* errorMessage = responseErrorDict[@"message"];
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [self showAlertWithTitle:@"Error getting Facebook Email" message:errorMessage];
                                               });
                                           }
                                       }
                                   }
                               }];
    }
}

#pragma mark Facebook: Post message to Facebook wall

-(IBAction)postToFacebook:(id)sender {
    if( [self.accessToken length] <= 0 ) {
        [self showAlertWithTitle:@"Error posting to Facebook" message:@"No access token available."];
    } else {

        NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[self getFacebookURLByAddingAccessToken:kFacebookPostOnWallURL]];
        [urlRequest setHTTPMethod:@"POST"];

        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                                   NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

                                   if( responseDictionary[@"error"] ) {
                                       NSDictionary* responseErrorDict = responseDictionary[@"error"];
                                       if( [responseErrorDict isKindOfClass:[NSDictionary class]] && responseErrorDict[@"message"] != nil ) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self showAlertWithTitle:@"Error posting to Facebook" message:responseErrorDict[@"message"]];
                                           });
                                       }
                                   } else {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self showAlertWithTitle:@"Successfully posted to Facebook" message:nil];
                                       });
                                   }
                               }];
    }
}

#pragma mark Facebook: URL helper methods

-(NSURL*)getFacebookURLByAddingAccessToken:(NSString*)facebookURL
{
    NSString* facebookURLString = [NSString stringWithFormat:@"%@&access_token=%@",facebookURL,[_accessTokenLabel text]];
    facebookURLString = [facebookURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:facebookURLString];
}

#pragma mark OAUTH2: Store, retrieve, and delete access and refresh tokens from keychain.

-(IBAction)storeTokens:(id)sender
{
    NSError* error = nil;
    [[_client dataClient] storeOAuth2TokensInKeychain:kKeychainItemNameForManuallySaving
                                          accessToken:self.accessToken
                                         refreshToken:self.refreshToken
                                                error:&error];

    if( error != nil && [self.accessToken length] <= 0 ) {
        [self showAlertWithTitle:@"No token found." message:@"No token was found to store."];
    }
}

-(IBAction)retrieveTokens:(id)sender
{
    [self resetTokensAndEmail];

    [[_client dataClient] retrieveStoredOAuth2TokensFromKeychain:kKeychainItemNameForManuallySaving
                                               completionHandler:^(NSString *accessToken, NSString *refreshToken, NSError *error) {
                                                   if( error == nil && [accessToken length] > 0 ) {
                                                       self.accessToken = accessToken;
                                                       self.refreshToken = refreshToken;
                                                       [[self accessTokenLabel] setText:self.accessToken];
                                                   } else {
                                                       [self showAlertWithTitle:@"No stored token found." message:nil];
                                                   }
                                               }];
}

-(IBAction)deleteStoredTokens:(id)sender
{
    [self resetTokensAndEmail];

    [[_client dataClient] removeStoredOAuth2TokensFromKeychain:kKeychainItemNameForManuallySaving];
}

@end
