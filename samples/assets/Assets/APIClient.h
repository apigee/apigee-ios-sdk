//
//  APIClient.h
//  Assets
//
//  Created by Robert Walsh on 10/7/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApigeeClient,ApigeeDataClient,ApigeeEntity,ApigeeClientResponse;

typedef void (^APIClientUploadCompletionHandler)(NSString *rawResponse, NSString* errorDescription);
typedef void (^APIClientDownloadCompletionHandler)(NSData *assetData, NSString* errorDescription);

@interface APIClient : NSObject

@property (nonatomic,strong) ApigeeClient* apigeeClient;
@property (nonatomic,weak) ApigeeDataClient* apigeeDataClient;
@property (nonatomic,strong) ApigeeEntity* pictureEntity;

+(instancetype)sharedClient;

-(void)attachAssetData:(NSData*)assetData
            completion:(APIClientUploadCompletionHandler)completionHandler;

-(void)retrieveAssetData:(APIClientDownloadCompletionHandler)completionHandler;

@end
