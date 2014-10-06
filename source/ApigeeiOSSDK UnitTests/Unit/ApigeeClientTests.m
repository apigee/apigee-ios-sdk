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

/*!
 @class ApigeeClientTests
 @abstract The ApigeeClientTests test case is used to validate the various ways of creating the ApigeeClient object.
 */
@interface ApigeeClientTests : XCTestCase

@end

@implementation ApigeeClientTests

-(BOOL)continueAfterFailure {
    return NO;
}

/*!
 @abstract Tests the creation of the ApigeeClient object using the - (id)initWithOrganizationId:(NSString*)theOrganizationId applicationId:(NSString*)theApplicationId initializer method.
 */
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

@end
