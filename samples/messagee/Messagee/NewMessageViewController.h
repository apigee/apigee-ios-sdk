//
//  NewMessageViewController.h
//  Messagee
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface NewMessageViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *messageTextField;
@property (nonatomic, strong) Client *client;

- (IBAction)postMessage:(id)sender;

@end
