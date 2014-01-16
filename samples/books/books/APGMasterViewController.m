//
//  APGMasterViewController.m
//  Books
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "APGMasterViewController.h"
#import "APGDetailViewController.h"
#import "APGNewBookViewController.h"

#import <ApigeeiOSSDK/Apigee.h>


@interface APGMasterViewController () {
    NSMutableArray *_objects;
}

@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;
@property (strong, nonatomic) ApigeeCollection* bookCollection;

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

- (void)showActivityIndicator
{
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect frame = self.activityIndicator.frame;
        frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
        frame.origin.y = self.view.frame.size.height / 2 - frame.size.height / 2;
        self.activityIndicator.frame = frame;
        [self.view addSubview:self.activityIndicator];
    }
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)hideActivityIndicator
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *) bar
{
    UITextField *searchBarTextField = nil;
    
    NSArray *views = ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) ? bar.subviews : [[bar.subviews objectAtIndex:0] subviews];
    
    for (UIView *subview in views)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchBarTextField = (UITextField *)subview;
            break;
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

- (void)showAlertTitle:(NSString*)title message:(NSString*)message
{
    UIAlertView* alert =
        [[UIAlertView alloc] initWithTitle:title
                                   message:message
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
    [alert show];
}

- (void)showBooksWithQuery:(ApigeeQuery*)query
{
    ApigeeDataClient* dataClient = [self.client dataClient];

    __block ApigeeCollection* collection;
    
    [_objects removeAllObjects];
    
    collection = [dataClient getCollection:@"book"
                                usingQuery:query
                         completionHandler:^(ApigeeClientResponse *result){
                             if ([result completedSuccessfully]) {
                                 while([collection hasNextEntity]) {
                                     ApigeeEntity* entity = [collection getNextEntity];
                                     [_objects addObject:entity];
                                 }
                                 
                                 if ([_objects count] > 0) {
                                     self.bookCollection = collection;
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self.tableView reloadData];
                                     });
                                 }
                             }
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self hideActivityIndicator];
                             });
                         }];
    
    [self showActivityIndicator];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#error configure your org name and app name here
    NSString* orgName = @"<YOUR_ORG_NAME>";
    NSString* appName = @"<YOUR_APP_NAME>";

    
    self.client =  [[ApigeeClient alloc] initWithOrganizationId:orgName applicationId:appName];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    _objects = [[NSMutableArray alloc] init];
    
    [self showBooksWithQuery:nil];
    
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
    
    NSMutableDictionary* entityProps = [[NSMutableDictionary alloc] init];
    [entityProps setValue:@"book" forKey:@"type"];
    [entityProps setValue:[book valueForKey:@"title"] forKey:@"title"];
    [entityProps setValue:[book valueForKey:@"author"] forKey:@"author"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ApigeeEntity* bookEntity = [self.bookCollection addEntity:entityProps];
    
        if (bookEntity) {
            [_objects insertObject:bookEntity atIndex:0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bookEntity) {
                [self.tableView reloadData];
            } else {
                [self showAlertTitle:@"Error" message:@"Unable to add new book"];
            }
        });
    });
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
    ApigeeEntity* entity = [_objects objectAtIndex:indexPath.row];
    NSString *title = [entity getStringProperty:@"title"];
    NSString *author = [entity getStringProperty:@"author"];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = author;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ApigeeEntity* entity = [_objects objectAtIndex:indexPath.row];
            ApigeeClientResponse* response = [self.bookCollection destroyEntity:entity];
            BOOL deletedBook = [response completedSuccessfully];
            
            if (deletedBook) {
                [_objects removeObjectAtIndex:indexPath.row];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (deletedBook) {
                    [tableView deleteRowsAtIndexPaths:@[indexPath]
                                     withRowAnimation:UITableViewRowAnimationFade];
                } else {
                    [self showAlertTitle:@"Error" message:@"Unable to delete book"];
                }
            });
        });
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //TODO: implement this functionality for iPad
        //NSDate *object = _objects[indexPath.row];
        //self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ApigeeEntity* entity = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:entity];
    } else if ([[segue identifier] isEqualToString:@"newBook"]) {
        APGNewBookViewController * vc = [[APGNewBookViewController alloc] init];
        [(APGNewBookViewController *)[segue destinationViewController] setDelegate:self];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    ApigeeQuery* query = nil;
    if ([searchBar.text length] > 0) {
        query = [[ApigeeQuery alloc] init];
        [query addRequirement:[NSString stringWithFormat:@"title='%@'",
                               searchBar.text]];
    } else {
        // we just pass nil for the query (i.e., return all)
    }
    
    [searchBar resignFirstResponder];
    
    [self showBooksWithQuery:query];
}

@end
