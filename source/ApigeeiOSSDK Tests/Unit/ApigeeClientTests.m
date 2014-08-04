//
//  ApigeeiOSSDK_Tests.m
//  ApigeeiOSSDK Tests
//
//  Created by Robert Walsh on 7/22/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Apigee.h"
#import "ApigeeAppIdentification.h"

static NSString* const kAPIOrgName = @"testOrgName";
static NSString* const kAPIAppID = @"testAppID";

@interface ApigeeClientTests : XCTestCase

@end

@implementation ApigeeClientTests

-(BOOL)continueAfterFailure {
    return NO;
}

- (void)test_ApigeeClientBasicCreation {
    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName
                                                                applicationId:kAPIAppID];

    // Assert the client and all its available properties are non-nil.
    XCTAssertNotNil(apigeeClient, @"ApigeeClient should not be nil.");
    XCTAssertNotNil([apigeeClient dataClient], @"ApigeeClient's dataClient should not be nil.");
    XCTAssertNotNil([apigeeClient monitoringClient], @"ApigeeClient's monitoringClient should not be nil.");
    XCTAssertNotNil([apigeeClient appIdentification], @"ApigeeClient's appIdentification should not be nil.");

    ApigeeAppIdentification* appIdentification = [apigeeClient appIdentification];

    // Assert the ApigeeAppIdentification and all its available properties are are set correctly.
    XCTAssertEqualObjects(kAPIOrgName, [appIdentification organizationId], @"ApigeeAppIdentification organization id are not equal.");
    XCTAssertEqualObjects(kAPIAppID, [appIdentification applicationId], @"ApigeeAppIdentification application id are not equal.");
    XCTAssertEqualObjects([ApigeeDataClient defaultBaseURL], [appIdentification baseURL], @"ApigeeAppIdentification baseURL are not equal.");
}

- (void)test_ApigeeAppIdentificationWithUUIDs {
    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName
                                                                applicationId:kAPIAppID];

    ApigeeAppIdentification* appIdentification = [apigeeClient appIdentification];

    // Assert the ApigeeAppIdentification and all its available properties are are set correctly.
    XCTAssertEqualObjects(kAPIOrgName, [appIdentification organizationId], @"ApigeeAppIdentification organization id are not equal.");
    XCTAssertEqualObjects(kAPIAppID, [appIdentification applicationId], @"ApigeeAppIdentification application id are not equal.");
    XCTAssertEqualObjects([ApigeeDataClient defaultBaseURL], [appIdentification baseURL], @"ApigeeAppIdentification baseURL are not equal.");
}

@end
