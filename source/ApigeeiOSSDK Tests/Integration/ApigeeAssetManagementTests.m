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

@interface ApigeeAssetManagementTests : XCTestCase

@end

@implementation ApigeeAssetManagementTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_AssetUploadAndDownload {

    static NSString* const kAPIOrgName = @"rwalsh";
    static NSString* const kAPIAppID = @"sandbox";

    static NSString* const kCollectionName = @"pictures";
    static NSString* const kEntityName = @"testAssetUploadCURL";

    static NSString* const kImageName = @"SampleData/assetManagementTestImage.png";
    static NSString* const kContentType = @"image/png";

    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName applicationId:kAPIAppID];
    ApigeeDataClient* dataClient = [apigeeClient dataClient];

    ApigeeClientResponse* picturesResponse = [dataClient getEntities:kCollectionName
                                                         queryString:[NSString stringWithFormat:@"name='%@'",kEntityName]];

    ApigeeEntity* pictureEntity = [picturesResponse firstEntity];
    XCTAssertNotNil(pictureEntity,@"pictureEntity should not be nil.");

    NSString* imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:kImageName ofType:nil];
    XCTAssertNotNil(imagePath,@"imagePath should not be nil.");

    NSData* imageData = [NSData dataWithContentsOfFile:imagePath];
    XCTAssertNotNil(imageData,@"imageData should not be nil.");

    ApigeeClientResponse* response = [dataClient attachAssetToEntity:pictureEntity
                                                           assetData:imageData
                                                       assetFileName:[kImageName lastPathComponent]
                                                    assetContentType:kContentType];

    XCTAssertTrue([response completedSuccessfully],@"Upload asset did not complete successfully.");

    NSData* serversImageData = [[dataClient getAssetDataForEntity:pictureEntity acceptedContentType:kContentType] response];
    XCTAssertEqualObjects(imageData, serversImageData,@"response's data should be the exact same as the imageData we uploaded.");

    UIImage* image = [UIImage imageWithData:serversImageData];
    XCTAssertNotNil(image,@"image could not be created with the returned data.");
}

@end
