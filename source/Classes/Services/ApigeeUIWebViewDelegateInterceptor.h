//
//  ApigeeUIWebViewDelegateIntercept.h
//  ApigeeAppMonitor
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @internal
 */
@interface ApigeeUIWebViewDelegateInterceptor : NSObject<UIWebViewDelegate>

- (id) initAndInterceptFor:(id<UIWebViewDelegate>) target;

- (BOOL) webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType;
- (void) webViewDidStartLoad:(UIWebView *) webView;
- (void) webViewDidFinishLoad:(UIWebView *) webView;
- (void) webView:(UIWebView *) webView didFailLoadWithError:(NSError *) error;

@end
