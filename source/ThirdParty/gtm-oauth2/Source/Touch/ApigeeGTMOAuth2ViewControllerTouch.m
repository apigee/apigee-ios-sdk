//
//  ApigeeGTMOAuth2ViewControllerTouch.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 11/7/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "ApigeeGTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"

@interface ApigeeGTMOAuth2ViewControllerTouch ()

@end

@implementation ApigeeGTMOAuth2ViewControllerTouch

+ (NSString *)authNibName {
    return nil;
}

+ (NSBundle *)authNibBundle {
    return nil;
}

- (void)viewDidLoad {

    self.webView = [[UIWebView alloc] init];
    [self.webView setDelegate:self];

    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.adjustsImageWhenDisabled = YES;
    self.backButton.adjustsImageWhenHighlighted = YES;
    self.backButton.alpha = 1.000;
    self.backButton.autoresizesSubviews = YES;
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.backButton.clearsContextBeforeDrawing = NO;
    self.backButton.clipsToBounds = NO;
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.backButton.contentMode = UIViewContentModeScaleToFill;
    self.backButton.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.backButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.backButton.enabled = YES;
    self.backButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    self.backButton.hidden = NO;
    self.backButton.highlighted = NO;
    self.backButton.multipleTouchEnabled = NO;
    self.backButton.opaque = NO;
    self.backButton.reversesTitleShadowWhenHighlighted = NO;
    self.backButton.selected = NO;
    self.backButton.showsTouchWhenHighlighted = NO;
    self.backButton.tag = 0;
    self.backButton.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    self.backButton.titleLabel.shadowOffset = CGSizeMake(0.0, -2.0);
    self.backButton.userInteractionEnabled = YES;
    [self.backButton setTitle:@"◀" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor colorWithWhite:1.000 alpha:1.000] forState:UIControlStateHighlighted];
    [self.backButton setTitleColor:[UIColor colorWithWhite:1.000 alpha:1.000] forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor colorWithRed:0.596078 green:0.686275 blue:0.952941 alpha:0.6] forState:UIControlStateDisabled];
    [self.backButton setTitleShadowColor:[UIColor colorWithWhite:0.500 alpha:1.000] forState:UIControlStateNormal];
    [self.backButton addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];

    self.forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.forwardButton.adjustsImageWhenDisabled = YES;
    self.forwardButton.adjustsImageWhenHighlighted = YES;
    self.forwardButton.alpha = 1.000;
    self.forwardButton.autoresizesSubviews = YES;
    self.forwardButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.forwardButton.clearsContextBeforeDrawing = NO;
    self.forwardButton.clipsToBounds = NO;
    self.forwardButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.forwardButton.contentMode = UIViewContentModeScaleToFill;
    self.forwardButton.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.forwardButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.forwardButton.enabled = YES;
    self.forwardButton.frame = CGRectMake(30.0, 0.0, 30.0, 30.0);
    self.forwardButton.hidden = NO;
    self.forwardButton.highlighted = NO;
    self.forwardButton.multipleTouchEnabled = NO;
    self.forwardButton.opaque = NO;
    self.forwardButton.reversesTitleShadowWhenHighlighted = NO;
    self.forwardButton.selected = NO;
    self.forwardButton.showsTouchWhenHighlighted = NO;
    self.forwardButton.tag = 0;
    self.forwardButton.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    self.forwardButton.titleLabel.shadowOffset = CGSizeMake(0.0, -2.0);
    self.forwardButton.userInteractionEnabled = YES;
    [self.forwardButton setTitle:@"▶" forState:UIControlStateNormal];
    [self.forwardButton setTitleColor:[UIColor colorWithWhite:1.000 alpha:1.000] forState:UIControlStateHighlighted];
    [self.forwardButton setTitleColor:[UIColor colorWithWhite:1.000 alpha:1.000] forState:UIControlStateNormal];
    [self.forwardButton setTitleColor:[UIColor colorWithRed:0.584314 green:0.67451 blue:0.952941 alpha:0.6] forState:UIControlStateDisabled];
    [self.forwardButton setTitleShadowColor:[UIColor colorWithWhite:0.500 alpha:1.000] forState:UIControlStateNormal];
    [self.forwardButton addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];

    self.navButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0, 30.0)];
    self.navButtonsView.alpha = 1.000;
    self.navButtonsView.autoresizesSubviews = YES;
    self.navButtonsView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.navButtonsView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.000];
    self.navButtonsView.clearsContextBeforeDrawing = NO;
    self.navButtonsView.clipsToBounds = NO;
    self.navButtonsView.contentMode = UIViewContentModeScaleToFill;
    self.navButtonsView.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.navButtonsView.frame = CGRectMake(0.0, 0.0, 60.0, 30.0);
    self.navButtonsView.hidden = NO;
    self.navButtonsView.multipleTouchEnabled = NO;
    self.navButtonsView.opaque = NO;
    self.navButtonsView.tag = 0;
    self.navButtonsView.userInteractionEnabled = YES;

    self.initialActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.initialActivityIndicator.alpha = 1.000;
    self.initialActivityIndicator.autoresizesSubviews = YES;
    self.initialActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.initialActivityIndicator.clearsContextBeforeDrawing = YES;
    self.initialActivityIndicator.clipsToBounds = NO;
    self.initialActivityIndicator.contentMode = UIViewContentModeScaleToFill;
    self.initialActivityIndicator.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.initialActivityIndicator.frame = CGRectMake(150.0, 115.0, 20.0, 20.0);
    self.initialActivityIndicator.hidden = NO;
    self.initialActivityIndicator.hidesWhenStopped = NO;
    self.initialActivityIndicator.multipleTouchEnabled = NO;
    self.initialActivityIndicator.opaque = NO;
    self.initialActivityIndicator.tag = 0;
    self.initialActivityIndicator.userInteractionEnabled = YES;
    [self.initialActivityIndicator startAnimating];

    [self.navButtonsView addSubview:self.backButton];
    [self.navButtonsView addSubview:self.forwardButton];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.initialActivityIndicator];

    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OAuth" style:UIBarButtonItemStylePlain target:nil action:nil];

    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.webView setFrame:self.view.frame];
    [super viewDidAppear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.webView setFrame:self.view.frame];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
