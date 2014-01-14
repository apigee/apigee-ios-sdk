//
//  ApigeeNSURLSessionDataTaskInfo.h
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 10/7/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApigeeNetworkEntry;

typedef void (^DataTaskCompletionBlock)(NSData*,NSURLResponse*,NSError*);

@interface ApigeeNSURLSessionDataTaskInfo : NSObject

@property (strong, nonatomic) NSURLSessionDataTask* sessionDataTask;
@property (strong, nonatomic) ApigeeNetworkEntry* networkEntry;
@property (copy, nonatomic) DataTaskCompletionBlock completionHandler;
@property (assign, nonatomic) NSUInteger dataSize;
@property (copy, nonatomic) id key;

- (void)debugPrint;

@end
