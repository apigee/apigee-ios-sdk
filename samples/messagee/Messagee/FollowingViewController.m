//
//  UsersViewController.m
//  Messagee
//
//  Created by Rod Simpson on 12/30/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import "FollowingViewController.h"
#import "FollowUserViewController.h"
#include <QuartzCore/QuartzCore.h>

@interface UIImage (TPAdditions)
- (UIImage*)imageScaledToSize:(CGSize)size;
@end

@implementation UIImage (TPAdditions)
- (UIImage*)imageScaledToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end


@interface FollowingViewController ()
{
    NSArray *following;
    UIImage *defaultUserImage;
}

@end


static NSString *CellIdentifier = @"followerCell";
static NSString *kSegueFollowUser = @"followUserSegue";

@implementation FollowingViewController

@synthesize client = _client;
@synthesize tv = _tv;

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
	
    NSString *imageFile = [[NSBundle mainBundle] pathForResource:@"user_profile"
                                                          ofType:@"png"];
    defaultUserImage = [[UIImage alloc] initWithContentsOfFile:imageFile];

    [_client getFollowing:^(NSArray *listFollowing) {
        following = listFollowing;
        [self.tv reloadData];
    }];
    UITabBarController *tabBarController = (UITabBarController *) self.parentViewController;
    tabBarController.tabBar.hidden = NO;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:kSegueFollowUser]){
        FollowUserViewController *dvc = [segue destinationViewController];
        [dvc setClient:_client];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [following count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *follower = [following objectAtIndex:indexPath.row];
    //user info
    NSString *username = [follower objectForKey:@"username"];
    
    //user image
    NSString *picture = [follower objectForKey:@"picture"];
    NSURL *pictureURL = [NSURL URLWithString:picture];
    
    UIImage *userImage;
    if (pictureURL && pictureURL.scheme && pictureURL.host) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: pictureURL];
        userImage = [UIImage imageWithData:imageData];
    } else {
        userImage = defaultUserImage;
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    [cell.textLabel setText:username];
    [cell.imageView setImage:userImage];
    
    return cell;
}

@end
