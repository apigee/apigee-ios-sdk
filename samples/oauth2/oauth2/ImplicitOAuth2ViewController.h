//
//  ImplicitOAuth2ViewController.h
//  oauth2
//
//  Created by Robert Walsh on 11/5/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ImplicitOAuth2ViewControllerCompletionHandler)(NSString *accessToken);

@interface ImplicitOAuth2ViewController : UIViewController <UIWebViewDelegate>

-(instancetype)initWithOAuthRequest:(NSURLRequest*)request
                        redirectURI:(NSString*)redirectURI
                  completionHandler:(ImplicitOAuth2ViewControllerCompletionHandler)completion;

@end
