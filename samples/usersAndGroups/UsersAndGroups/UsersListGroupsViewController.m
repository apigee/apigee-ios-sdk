//
//  UsersListGroupsViewController.m
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersListGroupsViewController.h"
#import "UsersAppDelegate.h"
#import "UsersAddGroupViewController.h"


@interface UsersListGroupsViewController ()

// An array to hold the retrieved group list.
@property (strong, nonatomic) NSMutableArray* groups;

@end


/**
 * Code behind the view that lists groups in the application.
 */
@implementation UsersListGroupsViewController

// An Apigee client to make requests of the application.
ApigeeClient *apigeeClient;

/**
 * Called after the view loads.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    UsersAppDelegate *appDelegate =
        (UsersAppDelegate *)[[UIApplication sharedApplication]delegate];
    apigeeClient = appDelegate.apigeeClient;
    
    self.tableView.rowHeight = 24.f;
    
    // Load data about groups from the application.
    [self loadGroupData];
    
    UIBarButtonItem *addButton =
        [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
            target:self
            action:@selector(insertNewGroup:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
}

/**
 * Retrieve group data from the application for display in the UI.
 *
 */
- (void)loadGroupData
{
    // Use an SDK method to retrieve group data.
    ApigeeClientResponse* result =
        [[apigeeClient dataClient] getEntities:@"groups" query:nil];

    // Get the group data as an array.
    self.groups = result.response[@"entities"];

    // If there weren't any groups retrieved, create an empty
    // array for the UI to use.
    if (self.groups.count == 0)
    {
        self.groups = [[NSMutableArray alloc] init];
    }

    // Refresh the table that lists the groups.
    [self.tableView reloadData];
}

/**
 * Add a new group to the application. This method is 
 * called from UsersAddGroupViewController.
 */
- (void)addGroup:(NSString *)name
            path:(NSString *)path
{
    // Call an SDK method to create the group with the
    // name and path values given in the UI.
    [[apigeeClient dataClient] createGroup:path
                                groupTitle:name
    completionHandler:^(ApigeeClientResponse *response)
    {
        if ([response completedSuccessfully])
        {
            // Refresh the UI with the new data.
            [self loadGroupData];
            [self.tableView reloadData];
        } else
        {
            NSLog(@"Unable to add");
        }
    }];
}

/**
 * Called when the add (+) button is clicked to seque
 * to the "add group" view. This method is bound to the
 * button when the view loads.
 */
- (void)insertNewGroup:(id)sender
{
    [self performSegueWithIdentifier:@"newGroup" sender:self];
}

/**
 * Called when the user clicks the Done button.
 */
- (IBAction)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// The following code is needed to configure the view.

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
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    NSString *groupPath = self.groups[indexPath.row][@"path"];
    cell.textLabel.text = groupPath;
    cell.textLabel.textAlignment = 1;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}

@end
