//
//  TabBarController.h
//  Messagee
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface TabBarController : UITabBarController

@property (nonatomic, strong) NSString *selectedView;
@property (nonatomic, strong) Client *client;

- (void)setNextViewToFollowing;

@end
