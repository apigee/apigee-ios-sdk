//
//  ApigeeStartViewController.h
//  geolocation
//
//  Created by Alex Muramoto on 2/6/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CoreLocation/CLLocationManagerDelegate.h>
#include <CoreLocation/CLError.h>
#include <CoreLocation/CLLocation.h>
#include <CoreLocation/CLLocationManager.h>

@interface ApigeeStartViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextField *orgField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *geoIndicator;
@end
