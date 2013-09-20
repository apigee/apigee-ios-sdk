//
//  FollowUserViewController.h
//  Messagee
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface FollowUserViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) Client * client;

- (IBAction)followButton:(id)sender;

@end
