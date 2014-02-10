//
//  ApigeeStartViewController.m
//  geolocation
//
//  Created by Alex Muramoto on 2/6/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

/* APIGEE iOS SDK GEOLOCATION EXAMPLE APP
 
 This sample app will show you how to perform basic geolocation
 operations using the Apigee iOS SDK, including:
 
 - creating entities with location data
 - retrieving entities by location
 
 Note that this app is designed to run using the unsecured 'sandbox' application
 that was automatically created for you when you signed up for the Apigee service.
 
 ** IMPORTANT - BEFORE YOU BEGIN **
 
 Be sure the Apigee iOS SDK is included in your Xcode project.
 
 For more information, see our SDK install guide:
 http://apigee.com/docs/app-services/content/installing-apigee-sdk-ios */

/* This is the UIViewController for the first screen in the app, where we get the
 user's organization name so we know what data store to access when making our API calls.
 
 We also retrieve the user's location.*/

#import "ApigeeStartViewController.h"
#import "ApigeeApiCalls.h"

@interface ApigeeStartViewController ()

@end

CLLocationManager *locationManager;
double latitude;
double longitude;

@implementation ApigeeStartViewController

// Dismiss keyboard when 'Go' button is tapped
- (BOOL)textFieldShouldReturn:(UITextField *)orgField
{
    [orgField resignFirstResponder];
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

// Initialize the SDK using the org name provided by the user
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *orgInput = self.orgField.text;
    [[[ApigeeApiCalls alloc] init] initializeSDK:orgInput];
}

// Get the user's location
- (void)viewWillAppear:(BOOL)animated
{
    [self startStandardUpdates];
    
}

// Display a message in case it takes a moment to retrieve the user's location
-(void)viewDidAppear:(BOOL)animated
{
    
    self.textView.text = @"Please wait while we get your location...";
    [self.startButton setHidden:YES];
    [self.orgField setHidden:YES];
}


/** These methods retrieve the user's location **/

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500; // meters
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        latitude = location.coordinate.latitude;
        longitude = location.coordinate.longitude;
    }
    [ApigeeApiCalls setLocation:latitude longitude:longitude];
    
    // Display the normal start screen once we have a user location
    self.textView.text = @"This sample app will show you how to perform basic geolocation operations using the Apigee iOS SDK, including:\n\n- Creating an entity with location data\n- Retrieving entities with a location query\n\nWe've already retrieved your location, so let's get started!\n\nTo begin, enter your Apigee organization name:";
    [self.startButton setHidden:NO];
    [self.orgField setHidden:NO];
    
}

@end
