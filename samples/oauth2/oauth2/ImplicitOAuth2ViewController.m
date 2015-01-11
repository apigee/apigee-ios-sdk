//
//  ImplicitOAuth2ViewController.m
//  oauth2
//
//  Created by Robert Walsh on 11/5/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "ImplicitOAuth2ViewController.h"

@interface ImplicitOAuth2ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic,strong) NSURLRequest* webViewRequest;
@property (nonatomic,strong) NSString* redirectURI;
@property (nonatomic,copy) ImplicitOAuth2ViewControllerCompletionHandler completionHandler;
@end

@implementation ImplicitOAuth2ViewController

-(instancetype)initWithOAuthRequest:(NSURLRequest*)request
                        redirectURI:(NSString*)redirectURI
                  completionHandler:(ImplicitOAuth2ViewControllerCompletionHandler)completion
{
    self = [super initWithNibName:nil bundle:nil];
    if( self )
    {
        _webViewRequest = request;
        _redirectURI = [redirectURI copy];
        _completionHandler = [completion copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self webView] loadRequest:[self webViewRequest]];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStartLoad = YES;
    BOOL hasDoneFinalRedirect = [self requestRedirectedToRequest:request];
    if (hasDoneFinalRedirect) {
        shouldStartLoad = NO;
        if( [self completionHandler] ) {
            NSString * q = [[request URL] absoluteString];
            NSString* stringToReplace = [NSString stringWithFormat:@"%@?#",[self redirectURI]];
            q = [q stringByReplacingOccurrencesOfString:stringToReplace withString:@""];
            NSArray* compontents = [q componentsSeparatedByString:@"&"];
            NSString* accessTokenString = [compontents firstObject];
            accessTokenString = [accessTokenString stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
            [self completionHandler](accessTokenString);
        }
    }
    return shouldStartLoad;
}

- (BOOL)requestRedirectedToRequest:(NSURLRequest *)redirectedRequest {
    NSString *redirectURI = self.redirectURI;
    if (redirectURI == nil) return NO;

    NSURL *redirectURL = [NSURL URLWithString:redirectURI];
    NSURL *requestURL = [redirectedRequest URL];

    NSString *requestHost = [requestURL host];
    NSString *requestPath = [requestURL path];
    NSString *redirectHost = [redirectURL host];
    NSString *redirectPath = [redirectURL path];

    BOOL isCallback = NO;
    if (requestHost && requestPath) {
        isCallback = [redirectHost isEqual:requestHost]
        && [redirectPath isEqual:requestPath];
    }

    return isCallback;
}

@end
