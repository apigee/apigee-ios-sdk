//
//  UsersAddGroupViewController.m
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersAddGroupViewController.h"
#import "UsersAppDelegate.h"

/**
 * A view controller behind the UI that adds a group
 * to the application.
 */
@implementation UsersAddGroupViewController

@synthesize path, name;

/**
 * Creates a new group in the application.
 */
-(IBAction)createGroup:(id)sender {
    // Adds a group to the application though an SDK method.
    [[self delegate] addGroup:name.text path:path.text];
    
    // Dismisses this UI after the group is added.
    [self.navigationController popViewControllerAnimated:YES];
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
