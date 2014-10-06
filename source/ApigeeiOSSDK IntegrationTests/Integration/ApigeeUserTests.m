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
#import "ApigeeIntegrationTestsConstants.h"

/*!
 @class ApigeeUserTests
 @abstract The ApigeeUserTests test case is used to test the flow of adding and manipulating a new/existing user.
 */

@interface NSURLRequest (ApplePrivate)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@interface ApigeeUserTests : XCTestCase

@property (nonatomic,strong) ApigeeClient* apigeeClient;

@end

@implementation ApigeeUserTests

-(BOOL)continueAfterFailure {
    return NO;
}

- (void)setUp {

    [super setUp];

    // This is a workaround for integration tests running with xctool/travis-ci.
    // Without this it always reports that retrieving config from server: The certificate for this server is invalid.
    // More info can be found here http://quellish.tumblr.com/post/33284931593/ssl-connections-from-an-ocunit-test-failing.
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES
                                       forHost:kAPIApigeeServer];

    ApigeeMonitoringOptions* options = [[ApigeeMonitoringOptions alloc] init];
    [options setMonitoringEnabled:NO];
    self.apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName applicationId:kAPIAppID options:options];
}

- (void)tearDown {

    self.apigeeClient = nil;

    [super tearDown];
}

/*!
 @abstract Tests creating a new ApigeeUser, the validity of that new users properties, logging that new user into the ApigeeDataClient, validating that the logged in user is correct, logging them out of the ApigeeDataClient, and then deleting the user.
 */
- (void)test_UserRegistrationLoginLogout {

    ApigeeDataClient* dataClient = [[self apigeeClient] dataClient];

    ApigeeClientResponse* addUserResponse = [dataClient addUser:kAPIUserTestUsername
                                                          email:kAPIUserTestEmail
                                                           name:kAPIUserTestName
                                                       password:kAPIUserTestPassword];

    XCTAssertTrue([addUserResponse completedSuccessfully], @"ApigeeDataClient addUser unsuccessful!");
    
    ApigeeEntity* responseEntity = [addUserResponse firstEntity];
    XCTAssertTrue([responseEntity isKindOfClass:[ApigeeUser class]], @"ApigeeDataClient addUser response entity is not kind of class ApigeeUser.");

    if( [responseEntity isKindOfClass:[ApigeeUser class]] )
    {
        ApigeeUser* createdUser = (ApigeeUser*) responseEntity;

        XCTAssertEqualObjects([createdUser username], kAPIUserTestUsername, @"Username is not equal.");
        XCTAssertEqualObjects([createdUser email], kAPIUserTestEmail, @"Email is not equal.");
        XCTAssertEqualObjects([createdUser name], kAPIUserTestName, @"User's name is not equal.");

        ApigeeClientResponse* loginResponse = [dataClient logInUser:kAPIUserTestUsername password:kAPIUserTestPassword];
        
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

    ApigeeClientResponse* loginResponse = [dataClient logInUser:kAPIUserTestUsername password:kAPIUserTestPassword];
    XCTAssertFalse([loginResponse completedSuccessfully], @"ApigeeDataClient loginResponse should have failed because the user created should no longer exist.");
}

@end
