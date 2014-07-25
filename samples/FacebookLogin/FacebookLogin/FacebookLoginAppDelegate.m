//
//  FacebookLoginAppDelegate.m
//  FacebookLogin
//
//  Created by Jeremy Anticouni on 7/16/14
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "FacebookLoginAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ApigeeiOSSDK/ApigeeClient.h>
#import <ApigeeiOSSDK/ApigeeDataClient.h>

@implementation FacebookLoginAppDelegate

#warning Set your FacebookAppID, FacebookDisplayName and CFBundleURLTypes in Info.plist before running the project.

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    if( self.dataClient != nil )
    {
        
        NSString * facebookToken = [[[FBSession activeSession] accessTokenData] accessToken];
        ApigeeClientResponse *response = [self.dataClient logInUserWithFacebook:facebookToken];
        
        return response;
        
    }
    
    return wasHandled;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          //[self sessionStateChanged:session state:state error:error];
                                      }];}

    //Replace 'AppDelegate' with the name of your app delegate class to instantiate it
    FacebookLoginAppDelegate *appDelegate = (FacebookLoginAppDelegate *)[[UIApplication sharedApplication] delegate];
    
#warning Set your ApigeeOrg and ApigeeApp values before running the project.
    
    NSString *orgName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ApigeeOrg"];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ApigeeApp"];
    
    //Instantiate ApigeeClient to initialize the SDK
    appDelegate.apigeeClient = [[ApigeeClient alloc]
                                initWithOrganizationId:orgName
                                applicationId:appName];
    
    //Retrieve instances of ApigeeClient.monitoringClient and ApigeeClient.dataClient
    self.monitoringClient = [appDelegate.apigeeClient monitoringClient]; //used to call App Monitoring methods
    self.dataClient = [appDelegate.apigeeClient dataClient]; //used to call data methods
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
