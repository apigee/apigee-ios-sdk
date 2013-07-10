//
//  NewMessageViewController.h
//  Messagee
//
//  Created by Rod Simpson on 12/28/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface NewMessageViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *messageTextField;
@property (nonatomic, strong) Client *client;

- (IBAction)postMessage:(id)sender;

@end
