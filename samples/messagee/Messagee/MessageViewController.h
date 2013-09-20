//
//  MessageViewController.h
//  Messagee
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface MessageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Client *client;
@property (nonatomic, weak) IBOutlet UITableView *tv;

@end
