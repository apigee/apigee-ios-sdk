//
//  ApigeeStartViewController.m
//  entities
//
//  Created by Alex Muramoto on 1/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

/* APIGEE iOS SDK ENTITY EXAMPLE APP
 
 This sample app will show you how to perform basic entity
 operations using the Apigee iOS SDK, including:
 
 - creating an entity
 - retrieving an entity
 - updating/altering an entity
 - deleting an entity
 
 Note that this app is designed to run using the unsecured 'sandbox' application
 that was automatically created for you when you signed up for the Apigee service.
 
 ** IMPORTANT - BEFORE YOU BEGIN **
 
 Be sure the Apigee iOS SDK is included in your Xcode project.
 
 For more information, see our SDK install guide:
http://apigee.com/docs/app-services/content/installing-apigee-sdk-ios */

/* This is the UIViewController for the first screen in the app, where we get the 
 user's organization name so we know what data store to access when making our API calls. */

#import "ApigeeStartViewController.h"
#import "ApigeeAppDelegate.h"
#import "ApigeeApiCalls.h"

@implementation ApigeeStartViewController

// Dismiss keyboard when 'Go' button is tapped
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get organization name from the UITextField
    NSString *orgInput = self.textField.text;
    if (sender != self.startButton) return;
    if (orgInput.length > 0) {
        
        /* Send the organization name to the initializeSDK method of the ApigeeApiCalls
           class to initialize the ApigeeClient class. This creates an instance of ApigeeDataClient
           class, which will specify our organization and application name for all of our calls to 
           the Apigee API */
        
        [[[ApigeeApiCalls alloc] init] initializeSDK:orgInput];
    }
}

@end
