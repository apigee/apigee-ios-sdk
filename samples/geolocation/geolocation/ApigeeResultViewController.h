//
//  ApigeeResultViewController.h
//  geolocation
//
//  Created by Alex Muramoto on 2/6/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApigeeResultViewController : UIViewController
@property NSString *action;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end
