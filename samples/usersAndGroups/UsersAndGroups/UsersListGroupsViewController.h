//
//  UsersListGroupsViewController.h
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersApiClient.h"

@protocol UsersListGroupsViewDelegate <NSObject>

//- (void)addGroup:(NSString *)name
//           path: (NSString *)path;

@end

@class UsersListUsersViewController;

@interface UsersListGroupsViewController : UITableViewController<UsersListGroupsViewDelegate>

@property (nonatomic, weak) UsersApiClient *apiClient;

@end
