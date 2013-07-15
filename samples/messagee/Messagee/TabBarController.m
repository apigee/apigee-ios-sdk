//
//  TabBarController.m
//  Messagee
//
//  Created by Rod Simpson on 12/28/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import "TabBarController.h"

static NSString *kFollowing = @"FOLLOWING";

@implementation TabBarController

@synthesize selectedView;
@synthesize client = _client;

- (void)setClient:(Client *)c {
    _client = c;
    [[[self viewControllers] objectAtIndex:0] setClient: _client];
    [[[self viewControllers] objectAtIndex:1] setClient: _client];
}

- (Client *)client {
    return _client;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([self.selectedView isEqualToString:kFollowing]) {
        self.selectedViewController = [[self viewControllers] objectAtIndex:1];
        self.selectedView = @"";
    }
}

- (void)setNextViewToFollowing {
    self.selectedView = kFollowing;
}

@end
