//
//  ApigeeUIWebView.m
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 10/24/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "ApigeeUIWebViewDelegateInterceptor.h"
#import "ApigeeUIWebView.h"

@interface ApigeeUIWebView()

@property (strong) ApigeeUIWebViewDelegateInterceptor *interceptor;

@end

@implementation ApigeeUIWebView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.interceptor = nil;
    }
    
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.interceptor = nil;
    }
    
    return self;
}

- (void) setDelegate:(id<UIWebViewDelegate>)delegate
{
    self.interceptor = [[ApigeeUIWebViewDelegateInterceptor alloc] initAndInterceptFor:delegate];
    [super setDelegate:self.interceptor];
}

@end
