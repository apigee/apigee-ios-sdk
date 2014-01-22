//
//  UsersAddUserToGroupViewController.m
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersAddUserToGroupViewController.h"
#import "UsersAppDelegate.h"

@interface UsersAddUserToGroupViewController ()

// A client instance for access to Apigee features.
@property (strong, nonatomic) ApigeeClient *apigeeClient;

// The group to which the current user should be
// added, set by selected the group in the UI.
@property (strong, nonatomic) NSString *selectedGroup;

@end


/**
 * A view controller behind the view for 
 * adding a user to a group.
 */
@implementation UsersAddUserToGroupViewController

@synthesize userName;  // The current user, set from the preceding view
@synthesize allGroupsArray;
@synthesize groupsForUserArray;
@synthesize groupsForUser;
@synthesize allGroups;

/**
 * Called after the view loads.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set an instance of the apigeeClient for us in this class.
    UsersAppDelegate *appDelegate =
        (UsersAppDelegate *)[[UIApplication sharedApplication]delegate];
    self.apigeeClient = appDelegate.apigeeClient;
    
    // Call functions that get lists of groups (those for the current
    // user and a full list) for display in the UI.
    [self loadGroupsForUser];
    [self loadAllGroups];
}

/**
 * Adds the current user to the selected group.
 */
-(IBAction)addUserToGroup:(id)sender
{

    // Add the user through a call to an SDK method.
    [[self.apigeeClient dataClient] addUserToGroup:userName group:self.selectedGroup
        completionHandler:^(ApigeeClientResponse *response)
    {
        if ([response completedSuccessfully]) {
            // If the attempt was successfull refresh the list of groups
            // this user is in.
            [self loadGroupsForUser];
        } else {
            [self displayAlert:@"Unable to add the user. Are they already in the group?"];
            NSLog(@"Unable to add a user to a group.");
        }
    }];
}

/**
 * Loads the list of groups the current user is
 * already in.
 */
- (void)loadGroupsForUser
{
    // Get the group list by calling an SDK method.
    [[self.apigeeClient dataClient] getGroupsForUser:userName
                              completionHandler:^(ApigeeClientResponse *result){
        if ([result completedSuccessfully]) {
            // If request was successful, load the group list
            // into an array for display in the UI.
            self.groupsForUserArray = result.response[@"entities"];
        } else {
            self.groupsForUserArray = [[NSMutableArray alloc] init];
        }
        self.groupsForUser.rowHeight = 20.f;
        // Reload the UI that lists the groups.
        [self.groupsForUser reloadData];
    }];
}

/**
 * Loads the full list of groups in the app.
 */
- (void)loadAllGroups
{
    // Get the collection of groups by calling an SDK method.
    ApigeeCollection *groupsCollection =
        [[self.apigeeClient dataClient] getCollection:@"groups"];
    if ([groupsCollection hasNextEntity])
    {
        // If there are groups in the return value,
        // load the list into an array for display in the UI.
        ApigeeClientResponse *result = [groupsCollection fetch];
        self.allGroupsArray = result.response[@"entities"];
    } else {
        self.allGroupsArray = [[NSMutableArray alloc] init];
    }
    // Reload the UI that displays the groups.
    [self.allGroups reloadAllComponents];
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
 * Called when the user clicks the Done button, dismissing
 * the current UI.
 */
- (IBAction)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// The following are needed to configure the view.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Picker view data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.allGroupsArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.allGroupsArray objectAtIndex:row][@"path"];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:nil size:12];
    label.textAlignment = 1;
    
    NSString *groupPath = self.allGroupsArray[row][@"path"];
    label.text = [NSString stringWithFormat:@" %@", groupPath];
    return label;
}

#pragma mark - Picker view delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedGroup = [self.allGroupsArray objectAtIndex:row][@"path"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupsForUserArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    NSString *groupPath = self.groupsForUserArray[indexPath.row][@"path"];
    cell.textLabel.text = groupPath;
    cell.textLabel.textAlignment = 1;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    return cell;
}

@end
