//
//  ViewController.h
//  Apigee App Services iOS Template
//
//  Created by Tim Anglade on 2/22/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) Client *client;

@end
