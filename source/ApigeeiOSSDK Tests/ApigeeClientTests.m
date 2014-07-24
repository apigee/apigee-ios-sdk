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

static NSString* const kAPI_Test_OrgName = @"rwalsh";
static NSString* const kAPI_Test_AppID = @"sandbox";

@interface ApigeeClientTests : XCTestCase

@property (nonatomic,strong) ApigeeClient* apigeeClient;

@end

@implementation ApigeeClientTests

-(void)setUp
{
    [super setUp];
}

-(void)tearDown
{
    [super tearDown];
}

- (void)test_ApigeeClientCreation {
    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPI_Test_OrgName
                                                       applicationId:kAPI_Test_AppID];

    // Assert the client and all its available properties are non-nil.
    XCTAssertNotNil(apigeeClient, @"ApigeeClient should not be nil.");
    XCTAssertNotNil([apigeeClient dataClient], @"ApigeeClient's dataClient should not be nil.");
    XCTAssertNotNil([apigeeClient monitoringClient], @"ApigeeClient's monitoringClient should not be nil.");
    XCTAssertNotNil([apigeeClient appIdentification], @"ApigeeClient's appIdentification should not be nil.");
}

- (void)test_ApigeeAppIdentification {
    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPI_Test_OrgName
                                                                applicationId:kAPI_Test_AppID];

    ApigeeAppIdentification* appIdentification = [apigeeClient appIdentification];

    // Assert the ApigeeAppIdentification and all its available properties are are set correctly.
    XCTAssertEqualObjects(kAPI_Test_OrgName, [appIdentification organizationId], @"ApigeeAppIdentification organization id are not equal.");
    XCTAssertEqualObjects(kAPI_Test_AppID, [appIdentification applicationId], @"ApigeeAppIdentification application id are not equal.");
    XCTAssertEqualObjects([ApigeeDataClient defaultBaseURL], [appIdentification baseURL], @"ApigeeAppIdentification baseURL are not equal.");
}

@end
