//
//  ApigeeAppIdentificationTests.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 7/28/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Apigee.h"
#import "ApigeeAppIdentification.h"

static NSString* const kAPIOrgName = @"testOrgName";
static NSString* const kAPIAppID = @"testAppID";
static NSString* const kAPIOrgUUID = @"4c735c7a-fb24-11e3-9064-b71444e51454";
static NSString* const kAPIAppUUID = @"c42bdc10-fb24-11e3-8452-25d3fc2d5ac5";

@interface ApigeeAppIdentificationTests : XCTestCase

@property (nonatomic,strong) ApigeeAppIdentification* apigeeAppIdentification;

@end

@implementation ApigeeAppIdentificationTests

- (void)test_CreationWithIDs {

    ApigeeAppIdentification* appIdentification = [[ApigeeAppIdentification alloc] initWithOrganizationId:kAPIOrgName
                                                                                           applicationId:kAPIAppID];

    XCTAssertNotNil(appIdentification, @"appIdentification should not be nil.");
    XCTAssertNotNil([appIdentification uniqueIdentifier], @"uniqueIdentifier should not be nil.");

    XCTAssertNil([appIdentification applicationUUID], @"applicationUUID should be nil.");
    XCTAssertNil([appIdentification organizationUUID], @"organizationUUID should be nil.");

    XCTAssertEqualObjects([appIdentification applicationId], kAPIAppID, @"applicationId should be equal to %@", kAPIAppID);
    XCTAssertEqualObjects([appIdentification organizationId], kAPIOrgName, @"organizationId should be equal to %@", kAPIOrgName);
    XCTAssertEqualObjects([appIdentification baseURL], [ApigeeDataClient defaultBaseURL], @"baseURL should be equal to %@", [ApigeeDataClient defaultBaseURL]);
}

- (void)test_CreationWithUUIDs {

    ApigeeAppIdentification* appIdentification = [[ApigeeAppIdentification alloc] initWithOrganizationUUID:kAPIOrgUUID
                                                                                           applicationUUID:kAPIAppUUID];

    XCTAssertNotNil(appIdentification, @"appIdentification should not be nil.");
    XCTAssertNotNil([appIdentification uniqueIdentifier], @"uniqueIdentifier should not be nil.");

    XCTAssertNil([appIdentification applicationId], @"applicationId should be nil.");
    XCTAssertNil([appIdentification organizationId], @"organizationId should be nil.");

    XCTAssertEqualObjects([appIdentification applicationUUID], kAPIAppUUID, @"applicationUUID should be equal to %@", kAPIAppUUID);
    XCTAssertEqualObjects([appIdentification organizationUUID], kAPIOrgUUID, @"organizationUUID should be equal to %@", kAPIOrgUUID);
    XCTAssertEqualObjects([appIdentification baseURL], [ApigeeDataClient defaultBaseURL], @"baseURL should be equal to %@", [ApigeeDataClient defaultBaseURL]);
}

@end
