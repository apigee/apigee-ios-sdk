//
//  TabBarController.h
//  Messagee
//
//  Created by Rod Simpson on 12/28/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface TabBarController : UITabBarController

@property (nonatomic, strong) NSString *selectedView;
@property (nonatomic, strong) Client *client;

- (void)setNextViewToFollowing;

@end
