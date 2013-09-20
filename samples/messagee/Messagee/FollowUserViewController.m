//
//  FollowUserViewController.m
//  Messagee
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "FollowUserViewController.h"
#import "TabBarController.h"

static NSString *kSegueReturnToFollowing = @"returnToFollowing";

@implementation FollowUserViewController

@synthesize usernameField;
@synthesize client = _client;

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
    [usernameField becomeFirstResponder];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)flag {
    [super viewWillAppear:flag];
    [usernameField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [usernameField becomeFirstResponder];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    [usernameField resignFirstResponder]; 
    if ([segue.identifier isEqualToString:kSegueReturnToFollowing]){
        TabBarController *dvc = [segue destinationViewController];
        [dvc setClient:_client];
        [dvc setNextViewToFollowing];
    }
}

- (IBAction)followButton:(id)sender {

    NSString * errorTitle = nil;
    NSString * errorMesssage = nil;
    
    if (![[usernameField text] isEqualToString:@""]) {
        
        [_client followUser:[usernameField text]
          completionHandler:^(ApigeeClientResponse *response) {
             if ([response completedSuccessfully]) {
                 //invoke segue back to message list
                 [self performSegueWithIdentifier:kSegueReturnToFollowing
                                           sender:self];
             } else {
                 NSString *errorTitle = @"Oops!";
                 NSString *errorMesssage = @"There was a problem following that user - check the username!";
                 UIAlertView* alert =
                 [[UIAlertView alloc] initWithTitle:errorTitle
                                            message:errorMesssage
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
                 [alert show];
             }
         }];
        
    } else {
        errorTitle = @"Oops!";
        errorMesssage = @"The user field was empty.";
    }
    
    if (errorTitle && errorMesssage) {
        UIAlertView* alert =
            [[UIAlertView alloc] initWithTitle:errorTitle
                                       message:errorMesssage
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
        [alert show];
        [usernameField becomeFirstResponder];
    }
}


@end
