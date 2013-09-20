//
//  APGMasterViewController.h
//  Books
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MasterViewDelegate <NSObject>

- (void)addNewBook:(NSDictionary *)book;

@end

@class ApigeeClient;
@class APGDetailViewController;

@interface APGMasterViewController : UITableViewController<MasterViewDelegate,UISearchBarDelegate>

@property (strong, nonatomic) APGDetailViewController *detailViewController;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) ApigeeClient *client;

@end
