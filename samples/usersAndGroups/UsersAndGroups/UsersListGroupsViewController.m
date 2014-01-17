//
//  UsersListGroupsViewController.m
//  UsersAndGroups
//
//  Created by Steve Traut on 1/8/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersListGroupsViewController.h"
#import "UsersAppDelegate.h"
#import "UsersAddGroupViewController.h"

@interface UsersListGroupsViewController ()
@end

/**
 * Code behind the view that lists groups in the application.
 */
@implementation UsersListGroupsViewController

@synthesize apiClient;

// An Apigee client to make requests of the application.
//ApigeeClient *apigeeClient;

// An array to hold the retrieved group list.
NSMutableArray *groups;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = 24.f;
    
    UsersAppDelegate *appDelegate =
        (UsersAppDelegate *)[[UIApplication sharedApplication]delegate];
    apiClient = [appDelegate apiClient];

    groups = [apiClient loadAllGroups];
    
    UIBarButtonItem *addButton =
        [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
            target:self
            action:@selector(insertNewGroup:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self.tableView reloadData];
}

- (void)insertNewGroup:(id)sender
{
    [self performSegueWithIdentifier:@"newGroup" sender:self];
}

- (IBAction)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"newGroup"]) {
        [(UsersAddGroupViewController *)[segue destinationViewController] setDelegate:self];
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
    return groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    NSString *groupPath = groups[indexPath.row][@"path"];
    cell.textLabel.text = groupPath;
    cell.textLabel.textAlignment = 1;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}

@end
