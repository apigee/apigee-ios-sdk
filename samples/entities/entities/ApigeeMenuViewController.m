//
//  ApigeeMenuViewController.m
//  entities
//
//  Created by Alex Muramoto on 1/15/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

/* APIGEE iOS SDK ENTITY EXAMPLE APP
 This ViewController displays the main menu for the app. The user can
 choose to create, retrieve, update or delete an entity.
 
 An entity must be created first, so that the app has an entity to
 perform retrieve, update, and delete operations on.
 */

#import "ApigeeMenuViewController.h"
#import "ApigeeResultViewController.h"
#import "ApigeeApiCalls.h"

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

- (void)viewWillAppear:(BOOL)animated {
    if ([ApigeeApiCalls getCurrentEntity] == nil) {
        [self disableButtons];
    } else {
        [self activateButtons];
    }
}

- (void) activateButtons {
    self.retrieveButton.enabled = TRUE;
    self.updateButton.enabled = TRUE;
    self.deleteButton.enabled = TRUE;
    self.retrieveButton.alpha = 1.0;
    self.updateButton.alpha = 1.0;
    self.deleteButton.alpha = 1.0;
}

- (void) disableButtons {
    self.retrieveButton.enabled = FALSE;
    self.updateButton.enabled = FALSE;
    self.deleteButton.enabled = FALSE;
    self.retrieveButton.alpha = 0.4;
    self.updateButton.alpha = 0.4;
    self.deleteButton.alpha = 0.4;
}

@end
