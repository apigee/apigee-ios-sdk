//
//  UsersAddGroupViewController.h
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersListGroupsViewController.h"

@interface UsersAddGroupViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextField *path;
@property (nonatomic, retain) IBOutlet UITextField *name;

@property (nonatomic, weak) id<UsersListGroupsViewDelegate> delegate;

@end
