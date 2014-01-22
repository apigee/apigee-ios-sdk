//
//  UsersListUsersViewController.m
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "UsersListUsersViewController.h"
#import "UsersAppDelegate.h"
#import "UsersAddUserViewController.h"

@interface UsersListUsersViewController ()

@property (strong, nonatomic) NSMutableArray* users;

@end


/**
 * Code behind the view that lists users in the application.
 */
@implementation UsersListUsersViewController

ApigeeClient *apigeeClient;

/**
 * Called after the view loads. Instantiates the Apigee client
 * and loads data that will be displayed.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Create the Apigee client object.
    UsersAppDelegate *appDelegate =
        (UsersAppDelegate *)[[UIApplication sharedApplication]delegate];
    apigeeClient = appDelegate.apigeeClient;
    
    self.tableView.rowHeight = 24.f;
    
    // Load data from the application for display in the UI.
    [self loadUserData];

    // Create the Add button and associate it with the
    // code that executes when it's clicked.
    UIBarButtonItem *addButton =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
         target:self
         action:@selector(insertNewUser:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
}

/**
 * Loads the list of users from the application.
 */
- (void)loadUserData
{
    // Get users from the application with an async SDK method.
    [[apigeeClient dataClient] getUsers:
     nil completionHandler:^(ApigeeClientResponse *result){
         // If the request was successful, assign the resulting list
         // to an array that will be used to display in the UI.
         if ([result completedSuccessfully]) {
             self.users = result.response[@"entities"];
         } else {
             self.users = [[NSMutableArray alloc] init];
         }
         // Reload the display with the retrieved user list.
         [self.tableView reloadData];
     }];
}

/**
 * Adds a new user to the application. This method is called
 * from the "add user" view when the user clicks the Add button.
 */
- (void)addUser:(NSString *)userName
           name:(NSString *)name
          email:(NSString *)email
       password:(NSString *)password
{
    // Use the received values to add a new user with an async SDK method.
    [[apigeeClient dataClient] addUser:userName
                                 email:email
                                  name:name
                              password:password
                     completionHandler:^(ApigeeClientResponse *response)
    {
        if ([response completedSuccessfully])
        {
            // Refresh the UI with the new data.
            [self loadUserData];
            [self.tableView reloadData];
        } else {
            NSLog(@"User add failed.");
        }
    }];
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
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    NSString *userName = self.users[indexPath.row][@"username"];
    cell.textLabel.text = userName;
    cell.textLabel.textAlignment = 1;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}

@end
