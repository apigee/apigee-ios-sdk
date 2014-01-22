//
//  UsersHomeViewController.m
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersHomeViewController.h"
#import "UsersAddUserToGroupViewController.h"

/**
 * Code behind the home screen view. Most connections from 
 * this view are defined as segues in the storyboard. The
 * addUserToGroup segue is handled here because it requires
 * logic around passing a value from this scene to another.
 */
@implementation UsersHomeViewController

/**
 * Called as the UI is about to segue from the home screen
 * to the "add user to group" screen.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addUserToGroup"])
    {
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        
        UsersAddUserToGroupViewController *addUserToGroupViewController =
            (UsersAddUserToGroupViewController *) [navController topViewController];
        
        // Pass the entered username value to the next screen.
        [addUserToGroupViewController setUserName:self.userName.text];
    }
}

/**
 * Called before displaying the form to add a user to a group.
 * The place to verify that a username was entered.
 */
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"addUserToGroup"])
    {
        // Pop up an alert if no username was entered.
        if ([[self.userName text] length] == 0)
        {
            [self displayAlert:@"Please enter a user name."];
            return NO;
        }
    }
    return YES;
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

// The code below is needed to configure the view.

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
