//
//  APGDetailViewController.h
//  Books
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApigeeEntity;

@interface APGDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) ApigeeEntity* detailItem;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *uuid;


@end
