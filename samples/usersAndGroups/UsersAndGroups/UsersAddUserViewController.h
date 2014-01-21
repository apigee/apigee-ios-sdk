//
//  UsersAddUserViewController.h
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersListUsersViewController.h"

@interface UsersAddUserViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextField *userName;
@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) IBOutlet UITextField *password;

@property (nonatomic, weak) id<UsersListUsersViewDelegate> delegate;

@end
