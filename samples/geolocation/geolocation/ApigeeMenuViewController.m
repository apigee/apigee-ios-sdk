//
//  ApigeeMenuViewController.m
//  geolocation
//
//  Created by Alex Muramoto on 2/6/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

/* APIGEE iOS SDK GEOLOCATION EXAMPLE APP
 This ViewController displays the main menu for the app. The user can
 choose to create entities with location data, then  retrieve them
 based on location. */

#import "ApigeeMenuViewController.h"
#import "ApigeeResultViewController.h"
#import "ApigeeApiCalls.h"

@interface ApigeeMenuViewController ()

@end

@implementation ApigeeMenuViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pass the segue indentifier to ApigeeResultViewController so the app knows which API method to call
    ApigeeResultViewController *resultController = (ApigeeResultViewController *)segue.destinationViewController;
    resultController.action = [segue identifier];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationItem.hidesBackButton = YES;
}

@end
