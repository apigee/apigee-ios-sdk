//
//  UsersAddUserToGroupViewController.m
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersAddUserToGroupViewController.h"
#import "UsersAppDelegate.h"

@interface UsersAddUserToGroupViewController ()
@end

/**
 * A view controller behind the view for 
 * adding a user to a group.
 */
@implementation UsersAddUserToGroupViewController

@synthesize userName, allGroupsArray, groupsForUserArray, groupsForUser, allGroups;

// The current user, set from the preceding view.
NSString *userName;
// The group to which the current user should be
// added, set by selected the group in the UI.
NSString *selectedGroup;

//NSMutableArray *users;
//NSMutableArray *groups;

@synthesize apiClient;

/**
 * Called after the view loads.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    UsersAppDelegate *appDelegate =
    (UsersAppDelegate *)[[UIApplication sharedApplication]delegate];
    apiClient = [appDelegate apiClient];
    
    // Call functions that get lists of groups (those for the current
    // user and a full list) for display in the UI.
    groupsForUserArray = [apiClient loadGroupsForUser:userName];
    allGroupsArray = [apiClient loadAllGroups];
}

/**
 * Adds the current user to the selected group.
 */
-(IBAction)addUserToGroup:(id)sender
{
    BOOL userAddedToGroup = [apiClient addUserToGroup:userName path:selectedGroup];
    
        if (userAddedToGroup) {
            allGroupsArray = [apiClient loadAllGroups];
        } else {
            [self displayAlert:@"Unable to add the user. Are they already in the group?"];
            NSLog(@"Unable to add a user to a group.");
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
    return [allGroupsArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [allGroupsArray objectAtIndex:row][@"path"];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:nil size:12];
    label.textAlignment = 1;
    
    NSString *groupPath = allGroupsArray[row][@"path"];
    label.text = [NSString stringWithFormat:@" %@", groupPath];
    return label;
}

#pragma mark - Picker view delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedGroup = [allGroupsArray objectAtIndex:row][@"path"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return groupsForUserArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    NSString *groupPath = groupsForUserArray[indexPath.row][@"path"];
    cell.textLabel.text = groupPath;
    cell.textLabel.textAlignment = 1;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    return cell;
}

@end
