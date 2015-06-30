//
//  FacebookLoginViewController.h
//  FacebookLogin
//
//  Created by Jeremy Anticouni on 7/16/14
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FacebookLoginViewDelegate <NSObject>

@end

@class FacebookLoginViewController;

@interface FacebookLoginViewController : UIViewController<FacebookLoginViewDelegate>

@property (nonatomic, weak) id<FacebookLoginViewDelegate> delegate;

@end
