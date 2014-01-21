//
//  UsersAddUserViewController.m
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersAddUserViewController.h"
#import "UsersAppDelegate.h"

/**
 * A view controller behind the UI that adds a user
 * to the application.
 */
@implementation UsersAddUserViewController

@synthesize userName, name, email, password, delegate;

/**
 * Creates a new user in the application from information provided
 * through fields in the UI.
 */
-(IBAction)createUser:(id)sender {
    // Adds a user to the application through an SDK method.
    [[self delegate] addUser:userName.text
                        name:name.text
                       email:email.text
                    password:password.text];
    
    // Dismisses this UI after the group is added.
    [self.navigationController popViewControllerAnimated:YES];
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
