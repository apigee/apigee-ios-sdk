//
//  MessageViewController.m
//  Messagee
//
//  Created by Rod Simpson on 12/29/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import "MessageViewController.h"
#import "NewMessageViewController.h"
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


@interface MessageViewController ()
{
    NSArray *messages;
    UIColor *borderColor;
    UIColor *usernameLabelTextColor;
    UIImage *balloonImage;
    UIImage *messageArrowImage;
    UIImage *defaultUserImage;
    UIFont *usernameLabelFont;
    UIFont *contentLabelFont;
    UIFont *userMessageFont;
}

@end


static const int kTagMessageView = 0;
static const int kTagBalloonView = 1;
static const int kTagContentLabel = 2;
static const int kTagUsernameLabel = 3;

static NSString *CellIdentifier = @"messageCell";


@implementation MessageViewController


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
	borderColor = [UIColor colorWithRed:0.169 green:0.169 blue:0.169 alpha:1];
    usernameLabelTextColor = [UIColor colorWithRed:0.392 green:0.682 blue:0.847 alpha:1];
    balloonImage = [[UIImage imageNamed:@"ballon.png"]
                    stretchableImageWithLeftCapWidth:14
                    topCapHeight:15];
    messageArrowImage = [UIImage imageNamed:@"messageArrow"];
    usernameLabelFont = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    contentLabelFont = [UIFont systemFontOfSize:14.0];
    userMessageFont = [UIFont fontWithName:@"Helvetica" size:11];
    NSString *imageFile = [[NSBundle mainBundle] pathForResource:@"user_profile" ofType:@"png"];
    defaultUserImage = [[UIImage alloc] initWithContentsOfFile:imageFile];
    [_client getMessages:^(NSArray *listMessages) {
        messages = listMessages;
        [self.tv reloadData];
    }];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"newMessageSegue"]){
        NewMessageViewController *dvc = [segue destinationViewController];
        [dvc setClient:_client];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *post = [messages objectAtIndex:indexPath.row];
    //main message
    NSString *message = [post objectForKey:@"content"];
    
	CGSize size = [message sizeWithFont:contentLabelFont
                      constrainedToSize:CGSizeMake(300, 9000)];
	return size.height + 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *post = [messages objectAtIndex:indexPath.row];
    //main message
    NSString *userMessage = [post objectForKey:@"content"];
    
    //subtitle
    NSDictionary *actor = [post objectForKey:@"actor"];
    NSString *username = [actor objectForKey:@"username"];
    
    //user image
    NSString *picture = [actor objectForKey:@"picture"];
    NSURL *pictureURL = [NSURL URLWithString:picture];
    
    UIImage *userImage;
    if (pictureURL && pictureURL.scheme && pictureURL.host) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: pictureURL];
        userImage = [UIImage imageWithData:imageData];
    } else {
        userImage = defaultUserImage;
    }
    

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView *balloonView;
	UILabel *contentLabel;
    UILabel *usernameLabel;

	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
		balloonView.tag = kTagBalloonView;
        
        usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        usernameLabel.backgroundColor = [UIColor clearColor];
		usernameLabel.textColor = usernameLabelTextColor;
        usernameLabel.font = usernameLabelFont;
        usernameLabel.tag = kTagUsernameLabel;
        
		contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.tag = kTagContentLabel;
		contentLabel.numberOfLines = 0;
		contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
		contentLabel.font = contentLabelFont;

        
		UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
		message.tag = kTagMessageView;
		[message addSubview:balloonView];
        [message addSubview:usernameLabel];
		[message addSubview:contentLabel];
		[cell.contentView addSubview:message];
		
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:messageArrowImage];
        imageView.center = CGPointMake(65, 30);
        [cell.contentView addSubview:imageView];
        
        
        cell.imageView.image = [userImage imageScaledToSize:CGSizeMake(42, 42)];
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 4;
        cell.imageView.layer.borderColor = [borderColor CGColor];
        cell.imageView.layer.borderWidth = 1;
	}
	else
	{
        UIView *messageView = [cell.contentView viewWithTag:kTagMessageView];
		balloonView = (UIImageView *)[messageView viewWithTag:kTagBalloonView];
        usernameLabel = (UILabel *)[messageView viewWithTag:kTagUsernameLabel];
		contentLabel = (UILabel *)[messageView viewWithTag:kTagContentLabel];
	}
	
	CGSize size = [userMessage sizeWithFont:userMessageFont
                          constrainedToSize:CGSizeMake(230.0f, 480.0f)
                              lineBreakMode:NSLineBreakByWordWrapping];
	
    balloonView.frame = CGRectMake(65, 15, 230, size.height + 50);
    contentLabel.frame = CGRectMake(70, 35, 210, size.height + 30);
    usernameLabel.frame = CGRectMake(70, 25, 230, 10);
    
    balloonView.image = balloonImage;
    usernameLabel.text = username;
	contentLabel.text = userMessage;
    
    return cell;
}

@end
