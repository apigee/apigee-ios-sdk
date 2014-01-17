//
//  UsersListUsersViewController.m
//  UsersAndGroups
//
//  Created by Steve Traut on 1/4/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersListUsersViewController.h"
#import "UsersAppDelegate.h"
#import "UsersAddUserViewController.h"
#import "UsersApiClient.h"

@interface UsersListUsersViewController ()
@end

/**
 * Code behind the view that lists users in the application.
 */
@implementation UsersListUsersViewController

NSMutableArray *users;

@synthesize apiClient;

/**
 * Called after the view loads. Instantiates the Apigee client
 * and loads data that will be displayed.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = 24.f;
    
    // Create the Apigee client object.
    UsersAppDelegate *appDelegate =
        (UsersAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    apiClient = [appDelegate apiClient];
    
    users = [apiClient loadUserData];
    [self.tableView reloadData];
    
//    [self getUserData];
    
    // Create the Add button and associate it with the
    // code that executes when it's clicked.
    UIBarButtonItem *addButton =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
         target:self
         action:@selector(insertNewUser:)];
    self.navigationItem.rightBarButtonItem = addButton;    
}

- (void)getUserData
{
    // Load data from the application for display in the UI.
    users = [apiClient loadUserData];
    
    [self.tableView reloadData];
}

/**
 * Called when the add (+) button is clicked to seque
 * to the "add user" view. This method is bound to the 
 * button when the view loads.
 */
- (void)insertNewUser:(id)sender
{
    [self performSegueWithIdentifier:@"newUser" sender:self];
}

/**
 * Called when the user clicks the Done button.
 */
-(IBAction)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// The following code is needed to configure the view.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"newUser"]) {
        [(UsersAddUserViewController *)[segue destinationViewController] setDelegate:self];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    NSString *userName = users[indexPath.row][@"username"];
    cell.textLabel.text = userName;
    cell.textLabel.textAlignment = 1;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}

@end
