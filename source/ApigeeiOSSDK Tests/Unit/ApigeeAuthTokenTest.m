//
//  ApigeeAuthTokenTest.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 7/30/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Apigee.h"
#import "ApigeeJsonUtils.h"

@interface ApigeeAuthTokenTest : XCTestCase

@property (nonatomic,strong) NSDictionary* tokenDictionary;

@end

@implementation ApigeeAuthTokenTest

- (void)setUp {

    [super setUp];

    NSString* jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SampleData/token.json" ofType:nil];

    NSData* jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];

    NSError* error = nil;
    self.tokenDictionary = [ApigeeJsonUtils decode:jsonString error:&error];

    XCTAssertNil(error, @"Error decoding token dictionary. Error : %@",error.description);
    XCTAssertNotNil(self.tokenDictionary, @"Token dictionary creation/decoding failed.");
    XCTAssertTrue([self.tokenDictionary isKindOfClass:[NSDictionary class]], @"Token JSON should be a dictionary object.");
}

- (void)tearDown {

    self.tokenDictionary = nil;

    [super tearDown];
}

- (void)test_AuthProperties {

    XCTAssertEqualObjects([[self tokenDictionary] valueForKey:@"access_token"], @"YWMt7J72Zg0fEeShX-l2bfgeBwAAAUdktenuCX-b_zZ_TvaOMAfcnBKgOFHJJ9U", @"access_token is not equal.");
    XCTAssertEqualObjects([[self tokenDictionary] objectForKey:@"expires_in"], [NSNumber numberWithFloat:604800], @"expires_in is not equal.");
}

- (void)test_UserProperties {

    ApigeeUser* user = [[ApigeeUser alloc] initWithDataClient:nil];
    [user addProperties:[[self tokenDictionary] objectForKey:@"user"]];

    XCTAssertEqual([user getFloatProperty:@"created"], 1403564520222, @"Created is %f expected \"1403564520222\".", [user getFloatProperty:@"created"]);
    XCTAssertEqual([user getFloatProperty:@"modified"], 1403564520222, @"Modified is %f expected \"1403564520222\".", [user getFloatProperty:@"modified"]);

    XCTAssertTrue([user activated], @"Activated is false and should be true.");
    XCTAssertFalse([user disabled], @"Disabled is true and should be false.");

    XCTAssertEqualObjects([user uuid], @"61fa03f4-fb2a-11e3-acca-39529b0acff6", @"UUID is %@ expected \"61fa03f4-fb2a-11e3-acca-39529b0acff6\".",[user uuid]);
    XCTAssertEqualObjects([user type], @"user", @"Type is %@ expected \"user\".",[user type]);
    XCTAssertEqualObjects([user name], @"Test User", @"Name is %@ expected \"Test User\".", [user name]);
    XCTAssertEqualObjects([user username], @"testuser", @"Username is %@ expected \"testuser\".",[user username]);
    XCTAssertEqualObjects([user email], @"rwalsh@apigee.com", @"Email is %@ expected \"rwalsh@apigee.com\".",[user email]);

    XCTAssertEqualObjects([user picture], @"http://www.gravatar.com/avatar/e466d447df831ddce35fbc50763fb03a", @"Picture is %@ expected \"http://www.gravatar.com/avatar/e466d447df831ddce35fbc50763fb03a\".", [user picture]);
}

@end
