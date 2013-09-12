//
//  APGMasterViewController.m
//  Books
//
//  Created by Matthew Dobson on 6/13/13.
//  Copyright (c) 2013 Matthew Dobson. All rights reserved.
//

#import "APGMasterViewController.h"

#import "APGDetailViewController.h"

#import "APGNewBookViewController.h"

#import <ApigeeiOSSDK/ApigeeClient.h>
#import <ApigeeiOSSDK/ApigeeDataClient.h>

@interface APGMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation APGMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#error configure your org name and app name here
    NSString* orgName = @"<YOUR_ORG_NAME>";
    NSString* appName = @"<YOUR_APP_NAME>";

    
    self.client =  [[ApigeeClient alloc] initWithOrganizationId:orgName applicationId:appName];
	// Do any additional setup after loading the view, typically from a nib.
    [[self.client dataClient] getEntities:@"book" query:nil
                        completionHandler:^(ApigeeClientResponse *result){
                            if (result.transactionState == kApigeeClientResponseSuccess) {
                                _objects = result.response[@"entities"];
                            } else {
                                _objects = [[NSMutableArray alloc] init];
                            }
                            [self.tableView reloadData];
                        }];

    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (APGDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)insertNewObject:(id)sender
{
    [self performSegueWithIdentifier:@"newBook" sender:self];
}

- (void)addNewBook:(NSDictionary *)book {
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    
    [[self.client dataClient] createEntity:@{@"type":@"book", @"title":book[@"title"], @"author":book[@"author"]}
                         completionHandler:^(ApigeeClientResponse *response){
        if (response.transactionState == kApigeeClientResponseSuccess) {
            [_objects insertObject:response.response[@"entities"][0] atIndex:0];
        } else {
            [_objects insertObject:@{@"title":@"error"} atIndex:0];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *title = _objects[indexPath.row][@"title"];
    NSString *author = _objects[indexPath.row][@"author"];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = author;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSDictionary *entity = [_objects objectAtIndex:indexPath.row];
        
        [[self.client dataClient] removeEntity:@"book"
                                      entityID:entity[@"uuid"]
                             completionHandler:^(ApigeeClientResponse *response){
                                 if (response.transactionState == kApigeeClientResponseSuccess) {
                                     [_objects removeObjectAtIndex:indexPath.row];
                                     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                 }
                             }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    } else if ([[segue identifier] isEqualToString:@"newBook"]) {
        APGNewBookViewController * vc = [[APGNewBookViewController alloc] init];
        [(APGNewBookViewController *)[segue destinationViewController] setDelegate:self];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    ApigeeQuery * query = [[ApigeeQuery alloc] init];
    [query addRequirement:[NSString stringWithFormat:@"title='%@'", searchBar.text]];
    [[self.client dataClient] getEntities:@"book"
                                    query:query
                        completionHandler:^(ApigeeClientResponse *result){
                            if (result.transactionState == kApigeeClientResponseSuccess) {
                                _objects = result.response[@"entities"];
                            } else {
                                _objects = [[NSMutableArray alloc] init];
                            }
                            [self.tableView reloadData];
                        }];
}

@end
