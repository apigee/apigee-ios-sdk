/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "NSDate+Apigee.h"
#import "ApigeeQueue+NetworkMetrics.h"
#import "ApigeeNetworkEntry.h"
#import "ApigeeUIWebViewDelegateInterceptor.h"
#import "ApigeeMonitoringClient.h"

@interface ApigeeUIWebViewDelegateInterceptor()

@property (weak) id<UIWebViewDelegate> target;
@property (strong) ApigeeNetworkEntry *networkEntry;
@end

@implementation ApigeeUIWebViewDelegateInterceptor

- (id) initAndInterceptFor:(id<UIWebViewDelegate>) target
{
    self = [super init];
    
    if (self) {
        self.target = target;
        self.networkEntry = [[ApigeeNetworkEntry alloc] init];
    }
    
    return self;
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (!self.networkEntry) {
        self.networkEntry = [[ApigeeNetworkEntry alloc] init];
    }
    
    [self.networkEntry populateWithRequest:request];

    if ( self.target && [self.target respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.target webView:(UIWebView *)webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }

    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *) webView
{
    [self.networkEntry recordStartTime];
    
    if (self.target && [self.target respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.target webViewDidStartLoad:webView];
    }
}

- (void) webViewDidFinishLoad:(UIWebView *) webView
{
    [self.networkEntry recordEndTime];
    
    if (self.target && [self.target respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.target webViewDidFinishLoad:webView];
    }
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [monitoringClient recordNetworkEntry:self.networkEntry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    self.networkEntry = nil;
}

- (void) webView:(UIWebView *) webView didFailLoadWithError:(NSError *) error
{
    [self.networkEntry recordEndTime];
    
    if (self.target && [self.target respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.target webView:webView didFailLoadWithError:error];
    }
    
    ApigeeMonitoringClient* monitoringClient = [ApigeeMonitoringClient sharedInstance];
    if (![monitoringClient isPaused]) {
        [self.networkEntry populateWithError:error];
        [monitoringClient recordNetworkEntry:self.networkEntry];
    } else {
        NSLog(@"Not capturing network metrics -- paused");
    }
    
    self.networkEntry = nil;
}


@end
