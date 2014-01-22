//
//  UsersAddUserToGroupViewController.h
//  UsersAndGroups
//
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersHomeViewController.h"

@interface UsersAddUserToGroupViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *groupsForUser;
@property (nonatomic, retain) IBOutlet UIPickerView *allGroups;
@property (nonatomic, retain) NSMutableArray *allGroupsArray;
@property (nonatomic, retain) NSMutableArray *groupsForUserArray;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, weak) id<UsersHomeViewDelegate> delegate;


@end
