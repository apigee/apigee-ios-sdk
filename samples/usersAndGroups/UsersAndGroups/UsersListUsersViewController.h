//
//  UsersListUsersViewController.h
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UsersListUsersViewDelegate <NSObject>

- (void)addUser:(NSString *)userName
           name: (NSString *)name
          email: (NSString *)email
       password: (NSString *)password;

@end

@class UsersListUsersViewController;

@interface UsersListUsersViewController : UITableViewController<UsersListUsersViewDelegate>

@end
