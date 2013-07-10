//
//  ApigeeUIWebView.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApigeeUIWebView : UIWebView

- (id) initWithCoder:(NSCoder *)aDecoder;
- (id) initWithFrame:(CGRect)frame;
- (void) setDelegate:(id<UIWebViewDelegate>)delegate;

@end
