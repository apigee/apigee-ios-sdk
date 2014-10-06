//
//  ApigeeAssetManagementTests.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 10/3/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Apigee.h"
#import "ApigeeIntegrationTestsConstants.h"
#import "ApigeeMonitoringOptions.h"

/*!
 @class ApigeeAssetManagementTests
 @abstract The ApigeeAssetManagementTests test case is used to test the flow of uploading and downloading an asset.
 */

@interface NSURLRequest (ApplePrivate)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@interface ApigeeAssetManagementTests : XCTestCase

@end

@implementation ApigeeAssetManagementTests

- (void)setUp {
    [super setUp];

    // This is a workaround for integration tests running with xctool/travis-ci.
    // Without this it always reports that retrieving config from server: The certificate for this server is invalid.
    // More info can be found here http://quellish.tumblr.com/post/33284931593/ssl-connections-from-an-ocunit-test-failing.
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES
                                       forHost:kAPIApigeeServer];
}

- (void)tearDown {
    [super tearDown];
}

/*!
 @abstract Tests the ability to upload an asset and connect it to an entity and follows that by downloading that asset to see if it is correct.
 */
- (void)test_AssetUploadAndDownload {

    ApigeeMonitoringOptions* options = [[ApigeeMonitoringOptions alloc] init];
    [options setMonitoringEnabled:NO];

    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName applicationId:kAPIAppID options:options];
    ApigeeDataClient* dataClient = [apigeeClient dataClient];

    ApigeeClientResponse* picturesResponse = [dataClient getEntities:kAPIAssetManagementTestCollectionName
                                                         queryString:[NSString stringWithFormat:@"name='%@'",kAPIAssetManagementTestEntityName]];

    ApigeeEntity* pictureEntity = [picturesResponse firstEntity];
    XCTAssertNotNil(pictureEntity,@"pictureEntity should not be nil.");

    NSString* imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:kAPIAssetManagementTestImageName ofType:nil];
    XCTAssertNotNil(imagePath,@"imagePath should not be nil.");

    NSData* imageData = [NSData dataWithContentsOfFile:imagePath];
    XCTAssertNotNil(imageData,@"imageData should not be nil.");

    ApigeeClientResponse* response = [dataClient attachAssetToEntity:pictureEntity
                                                           assetData:imageData
                                                       assetFileName:[kAPIAssetManagementTestImageName lastPathComponent]
                                                    assetContentType:kAPIAssetManagementTestContentType];

    XCTAssertTrue([response completedSuccessfully],@"Upload asset did not complete successfully.");

    NSData* serversImageData = [[dataClient getAssetDataForEntity:pictureEntity acceptedContentType:kAPIAssetManagementTestContentType] response];
    XCTAssertEqualObjects(imageData, serversImageData,@"response's data should be the exact same as the imageData we uploaded.");

    UIImage* image = [UIImage imageWithData:serversImageData];
    XCTAssertNotNil(image,@"image could not be created with the returned data.");
}

@end
