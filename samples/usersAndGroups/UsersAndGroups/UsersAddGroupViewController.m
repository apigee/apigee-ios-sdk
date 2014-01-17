//
//  UsersAddGroupViewController.m
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersAddGroupViewController.h"
#import "UsersAppDelegate.h"

@interface UsersAddGroupViewController ()

@end

/**
 * A view controller behind the UI that adds a group
 * to the application.
 */
@implementation UsersAddGroupViewController

@synthesize path, name, apiClient;

/**
 * Creates a new group in the application.
 */
-(IBAction)createGroup:(id)sender {
    // Adds a group to the application though an SDK method.
    BOOL groupAdded = [apiClient addGroup:name.text path:path.text];
    
    if(groupAdded)
    {
        // Dismisses this UI after the group is added.
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self displayAlert:@"Unable to add the group."];
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


/**
 * Called when the Cancel button is clicked.
 */
- (IBAction)cancel:(id)sender
{
    // Dismisses the current UI.
    [self.navigationController popViewControllerAnimated:YES];
}

// The following are used to configure the view.

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
