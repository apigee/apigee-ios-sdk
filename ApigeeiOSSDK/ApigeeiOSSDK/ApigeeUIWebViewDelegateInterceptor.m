//
//  ApigeeUIWebViewDelegateIntercept.m
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 10/24/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import "NSDate+Apigee.h"
#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeUIWebViewDelegateInterceptor.h"

@interface ApigeeUIWebViewDelegateInterceptor()

@property (assign) id<UIWebViewDelegate> target;
@property (strong) NSString *url;
@property (strong) NSDate *started;
@end

@implementation ApigeeUIWebViewDelegateInterceptor

- (id) initAndInterceptFor:(id<UIWebViewDelegate>) target
{
    self = [super init];
    
    if (self) {
        self.target = target;
    }
    
    return self;
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.url = [request.URL absoluteString];

    if ( self.target && [self.target respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.target webView:(UIWebView *)webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }

    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *) webView
{
    self.started = [NSDate date];
    
    if (self.target && [self.target respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.target webViewDidStartLoad:webView];
    }
}

- (void) webViewDidFinishLoad:(UIWebView *) webView
{
    NSDate *ended = [NSDate date];
    
    if (self.target && [self.target respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.target webViewDidFinishLoad:webView];
    }
    
    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] initWithURL:self.url
                                                                    started:self.started
                                                                      ended:ended];
    [ApigeeQueue recordNetworkEntry:entry];
}

- (void) webView:(UIWebView *) webView didFailLoadWithError:(NSError *) error
{
    NSDate *ended = [NSDate date];
    
    if (self.target && [self.target respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.target webView:webView didFailLoadWithError:error];
    }
    
    ApigeeNetworkEntry *entry = [[ApigeeNetworkEntry alloc] initWithURL:self.url
                                                                    started:self.started
                                                                      ended:ended];
    entry.numErrors = @"1";
    entry.transactionDetails = [error localizedDescription];
    [ApigeeQueue recordNetworkEntry:entry];
}


@end
