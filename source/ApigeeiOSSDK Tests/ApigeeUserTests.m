//
//  ApigeeUserTests.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 7/23/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Apigee.h"
#import "ApigeeUser.h"

static NSString* const kAPIOrgName = @"rwalsh";
static NSString* const kAPIAppID = @"sandbox";

static NSString* const kAPITestUsername = @"testUser";
static NSString* const kAPITestEmail = @"testUser@apigee.com";
static NSString* const kAPITestName = @"Test User";
static NSString* const kAPITestPassword = @"password";

@interface ApigeeUserTests : XCTestCase

@property (nonatomic,strong) ApigeeClient* apigeeClient;

@end

@implementation ApigeeUserTests

- (void)setUp {

    [super setUp];

    self.apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName
                                                       applicationId:kAPIAppID];
}

- (void)tearDown {

    self.apigeeClient = nil;

    [super tearDown];
}

- (void)test_UserRegistrationLoginLogout {

    ApigeeDataClient* dataClient = [[self apigeeClient] dataClient];

    ApigeeClientResponse* addUserResponse = [dataClient addUser:kAPITestUsername
                                                          email:kAPITestEmail
                                                           name:kAPITestName
                                                       password:kAPITestPassword];

    XCTAssertTrue([addUserResponse completedSuccessfully], @"ApigeeDataClient addUser unsuccessful!");
    
    ApigeeEntity* responseEntity = [addUserResponse firstEntity];
    XCTAssertTrue([responseEntity isKindOfClass:[ApigeeUser class]], @"ApigeeDataClient addUser response entity is not kind of class ApigeeUser.");

    if( [responseEntity isKindOfClass:[ApigeeUser class]] )
    {
        ApigeeUser* createdUser = (ApigeeUser*) responseEntity;

        XCTAssertEqualObjects([createdUser username], kAPITestUsername, @"Username is not equal.");
        XCTAssertEqualObjects([createdUser email], kAPITestEmail, @"Email is not equal.");
        XCTAssertEqualObjects([createdUser name], kAPITestName, @"User's name is not equal.");

        ApigeeClientResponse* loginResponse = [dataClient logInUser:kAPITestUsername password:kAPITestPassword];
        
        XCTAssertTrue([loginResponse completedSuccessfully], @"ApigeeDataClient loginResponse unsuccessful.");
        XCTAssertNotNil([dataClient getAccessToken], @"ApigeeDataClient should have an accessToken.");

        ApigeeUser* loggedInUser = [dataClient getLoggedInUser];

        XCTAssertEqualObjects([loggedInUser uuid], [createdUser uuid], @"Logged in user and created users uuids aren't equal.");
        XCTAssertEqualObjects([loggedInUser username], [createdUser username], @"Logged in user and created user usernames aren't equal.");
        XCTAssertEqualObjects([loggedInUser email], [createdUser email], @"Logged in user and created users emails aren't equal.");
        XCTAssertEqualObjects([loggedInUser name], [createdUser name], @"Logged in user and created users names aren't equal.");

        [dataClient logOut:[loggedInUser username]];

        XCTAssertNil([dataClient getAccessToken], @"ApigeeDataClient should not have an accessToken.");
    }

    ApigeeClientResponse* deleteCreatedUserResponse = [dataClient removeEntity:@"user" entityID:[responseEntity uuid]];
    XCTAssertTrue([deleteCreatedUserResponse completedSuccessfully], @"ApigeeDataClient remove created user failed.");

    ApigeeClientResponse* loginResponse = [dataClient logInUser:kAPITestUsername password:kAPITestPassword];
    XCTAssertFalse([loginResponse completedSuccessfully], @"ApigeeDataClient loginResponse should have failed because the user created should no longer exist.");
}

@end
