//
//  MessageViewController.h
//  Messagee
//
//  Created by Rod Simpson on 12/29/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface MessageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Client *client;

@end
