//
//  ApigeeUIWebViewDelegateIntercept.h
//  ApigeeAppMonitor
//
//  Created by jaminschubert on 10/24/12.
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApigeeUIWebViewDelegateInterceptor : NSObject<UIWebViewDelegate>

- (id) initAndInterceptFor:(id<UIWebViewDelegate>) target;

- (BOOL) webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType;
- (void) webViewDidStartLoad:(UIWebView *) webView;
- (void) webViewDidFinishLoad:(UIWebView *) webView;
- (void) webView:(UIWebView *) webView didFailLoadWithError:(NSError *) error;

@end
