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

ApigeeClient *apigeeClient;

/**
 * Creates a new user in the application from information provided
 * through fields in the UI.
 */
-(IBAction)createUser:(id)sender {
    
    NSString *userNameValue = userName.text;
    NSString *nameValue = name.text;
    NSString *emailValue = email.text;
    NSString *passwordValue = password.text;

    // Create a query instance specifying the path that
    // was requested for the new group.
    ApigeeQuery *query = [[ApigeeQuery alloc] init];
    [query addRequirement:[NSString stringWithFormat:@"username='%@'", userNameValue]];

    
    // Find out if there's already a user with this username. Some callback
    // methods have been omitted for brevity.
    [[apigeeClient dataClient] getUsers:query
                      completionHandler:^(ApigeeClientResponse *usersResponse)
    {
        if ([usersResponse completedSuccessfully])
        {
            if ([usersResponse.response[@"entities"] count] > 0)
            {
                // If any entities were returned, it means there's a
                // user with that username.
                [self displayAlert:@"That username is taken. Please choose another."];
            } else {
                // If no entities, add a new user with an async SDK method.
                [[self delegate] addUser:userNameValue
                                    name:nameValue
                                   email:emailValue
                                password:passwordValue];
            }
        } else {
            // Log (or display) a message.
            ApigeeLogError(@"AddUser", @"Error while getting user data.");
        }
    }];
    
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
