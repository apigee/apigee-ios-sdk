//
//  APIClient.m
//  Assets
//
//  Created by Robert Walsh on 10/7/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import "APIClient.h"

#import <ApigeeiOSSDK/Apigee.h>

static NSString* const kAPIOrgName = @"<YOUR ORG NAME>";
static NSString* const kAPIAppName = @"sandbox";

static NSString* const kAPIEntityType = @"pictures";
static NSString* const kAPIEntityName = @"testAssetUpload";
static NSString* const kAPIImageName = @"testAssetUpload.png";
static NSString* const kAPIContentType = @"image/png";

@interface APIClient ()

@end

@implementation APIClient

+(instancetype)sharedClient
{
    static APIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

-(instancetype)init
{
    self = [super init];
    if( self != nil ) {

        _apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName applicationId:kAPIAppName];
        _apigeeDataClient = [_apigeeClient dataClient];

        if( _apigeeDataClient ) {
            [self retrievePictureEntityFromServer];
        }
    }
    return self;
}

-(void)retrievePictureEntityFromServer
{
    // Note we do these requests on the main thread here for ease of example.  Normally you would want to make these asynchronous.
    ApigeeClientResponse* response = [[self apigeeDataClient] getEntities:kAPIEntityType
                                                              queryString:[NSString stringWithFormat:@"name='%@'",kAPIEntityName]];

    if( [response completedSuccessfully] && [response firstEntity] != nil ) {
        [self setPictureEntity:[response firstEntity]];
    } else {
        // If we couldn't find the entity lets go ahead and try to create one.
        response = [[self apigeeDataClient] createEntity:@{@"type":kAPIEntityType, @"name":kAPIEntityName}];
        if( [response completedSuccessfully] && [response firstEntity] ) {
            [self setPictureEntity:[response firstEntity]];
        }
    }
}

-(void)retrieveAssetData:(APIClientDownloadCompletionHandler)completionHandler
{
    // Grab the entity's asset data
    [[self apigeeDataClient] getAssetDataForEntity:[self pictureEntity]
                               acceptedContentType:kAPIContentType
                                 completionHandler:^(ApigeeClientResponse *response) {
                                     if( [response completedSuccessfully] ) {
                                         if( completionHandler ) {
                                             completionHandler([response response],nil);
                                         }
                                     } else {
                                         if( completionHandler ) {
                                             completionHandler(nil,[response errorDescription]);
                                         }
                                     }
                                 }];
}

-(void)attachAssetData:(NSData*)assetData completion:(APIClientUploadCompletionHandler)completionHandler
{
    // Attach the asset data to the entity
    [[self apigeeDataClient] attachAssetToEntity:[self pictureEntity]
                                       assetData:assetData
                                   assetFileName:kAPIImageName
                                assetContentType:kAPIContentType
                               completionHandler:^(ApigeeClientResponse *response) {
                                   if( [response completedSuccessfully] ) {
                                       if( completionHandler ) {
                                           completionHandler([response rawResponse],nil);
                                       }
                                   } else {
                                       if( completionHandler ) {
                                           completionHandler([response rawResponse],[response errorDescription]);
                                       }
                                   }
                               }];
}


@end
