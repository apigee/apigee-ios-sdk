//
//  UsersViewController.h
//  Messagee
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface FollowingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Client *client;
@property (weak, nonatomic) IBOutlet UITableView *tv;

@end
