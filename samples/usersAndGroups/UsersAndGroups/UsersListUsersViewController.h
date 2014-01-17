//
//  UsersListUsersViewController.h
//  UsersAndGroups
//
//  Created by Steve Traut on 1/4/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersApiClient.h"

@protocol UsersListUsersViewDelegate <NSObject>
@end

@class UsersListUsersViewController;

@interface UsersListUsersViewController : UITableViewController<UsersListUsersViewDelegate>

- (void)getUserData;

@property (nonatomic, weak) UsersApiClient *apiClient;

@end
