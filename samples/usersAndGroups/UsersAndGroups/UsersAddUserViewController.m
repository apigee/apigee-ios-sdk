//
//  UsersAddUserViewController.m
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersAddUserViewController.h"
#import "UsersAppDelegate.h"
#import "UsersApiClient.h"

@interface UsersAddUserViewController ()

@end

/**
 * A view controller behind the UI that adds a user
 * to the application.
 */
@implementation UsersAddUserViewController

@synthesize userName, name, email, password, delegate, apiClient;

/**
 * Creates a new user in the application from information provided
 * through fields in the UI.
 */
-(IBAction)addUser:(id)sender {
    // Adds a user to the application through an SDK method.
    
    BOOL userAdded = [[self apiClient] addUser:userName.text
                        name:name.text
                       email:email.text
                    password:password.text];
    
    if (userAdded)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self displayAlert:@"Unable to add the user."];
    }
}

/**
 * Displays an alert message.
 */
- (void)displayAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Users and Groups"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


/*
 * Called when the Cancel button is clicked. Dismisses the 
 * current UI.
 */
-(IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// The following are used in creating and configuring the view.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
