//
//  ApigeeAppDelegate.m
//  entities
//
//  Created by Alex Muramoto on 1/14/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "ApigeeAppDelegate.h"
#import <ApigeeiOSSDK/Apigee.h>
#import "ApigeeResultViewController.h"

@implementation ApigeeAppDelegate

// Actual initialization of the ApigeeClient class. This is called from ApigeeApiCalls.m.
- (void)initializeSDKInAppDelegate:(NSString*)appName forOrg:(NSString*)orgName {
    self.apigeeClient = [[ApigeeClient alloc]
                         initWithOrganizationId:orgName // The user's organization name
                         applicationId:appName]; // The user's application name. In this case 'sandbox' by default.

    //Retrieve instances of ApigeeClient.monitoringClient and ApigeeClient.dataClient
    self.monitoringClient = [self.apigeeClient monitoringClient]; //used to call App Monitoring methods
    self.dataClient = [self.apigeeClient dataClient]; //used to call data methods
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Just some navigation bar customization
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:1.0 green:(67/255) blue:0 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    NSShadow *shadow = [[NSShadow alloc] init];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:16.0], NSFontAttributeName, nil]];
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

-(UIColor*)colorWithHexString:(NSString*)hex
    {
        NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        
        // String should be 6 or 8 characters
        if ([cString length] < 7) return [UIColor grayColor];
        
        // strip 0X if it appears
        if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
        
        if ([cString length] != 7) return  [UIColor grayColor];
        
        // Separate into r, g, b substrings
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString *rString = [cString substringWithRange:range];
        
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        
        // Scan values
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)  
                               alpha:1.0f];  
    }

@end
