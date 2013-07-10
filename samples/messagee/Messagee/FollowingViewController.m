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

@implementation FollowingViewController

@synthesize client = _client;

- (void)setClient:(Client *)c {
    _client = c;
}

- (Client *)client {
    return _client;
}

NSArray *following;


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
	
    following = [_client getFollowing];
    ((UITabBarController *) self.parentViewController).tabBar.hidden
    = NO;
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"followUserSegue"]){
        FollowUserViewController *dvc = [segue destinationViewController];
        [dvc setClient:_client];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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
        NSString *imageFile = [[NSBundle mainBundle] pathForResource:@"user_profile" ofType:@"png"];
        userImage = [[UIImage alloc] initWithContentsOfFile:imageFile];
    }
    
    
    
    static NSString *CellIdentifier = @"followerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell.textLabel setText:username];
    [cell.imageView setImage:userImage];
    
    return cell;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
