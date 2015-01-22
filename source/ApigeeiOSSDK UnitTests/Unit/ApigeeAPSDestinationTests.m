//
//  ApigeeAPSDestinationTests.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 1/22/15.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ApigeeAPSDestination.h"

@interface ApigeeAPSDestinationTests : XCTestCase

@end

@implementation ApigeeAPSDestinationTests

- (void)test_allDevices {
    ApigeeAPSDestination* destination = [ApigeeAPSDestination destinationAllDevices];
    XCTAssertNotNil(destination,@"All devices destination should not be nil.");
    XCTAssertEqualObjects([destination deliveryPath], @"devices/*", @"All devices destination delivery path should be 'devices/*'");
}

- (void)test_singleDevice {
    ApigeeAPSDestination* destination = [ApigeeAPSDestination destinationSingleDevice:@"231f60f6-0b86-4baa-ade9-d2b6436007a2"];
    XCTAssertNotNil(destination,@"Single device destination should not be nil.");
    XCTAssertEqualObjects([destination deliveryPath], @"devices/231f60f6-0b86-4baa-ade9-d2b6436007a2", @"Single device destination delivery path should be 'devices/231f60f6-0b86-4baa-ade9-d2b6436007a2'");
}

- (void)test_multipleDevices {
    ApigeeAPSDestination* destination = [ApigeeAPSDestination destinationMultipleDevices:@[@"231f60f6-0b86-4baa-ade9-d2b6436007a2",@"75c52ce7-af82-4d91-937e-ad13e0dc78d0"]];
    XCTAssertNotNil(destination,@"Multiple devices destination should not be nil.");
    XCTAssertEqualObjects([destination deliveryPath], @"devices/231f60f6-0b86-4baa-ade9-d2b6436007a2;75c52ce7-af82-4d91-937e-ad13e0dc78d0", @"Multiple devices destination delivery path should be 'devices/231f60f6-0b86-4baa-ade9-d2b6436007a2;75c52ce7-af82-4d91-937e-ad13e0dc78d0'");
}

- (void)test_singleUser {
    ApigeeAPSDestination* destination = [ApigeeAPSDestination destinationSingleUser:@"testUser"];
    XCTAssertNotNil(destination,@"Single user destination should not be nil.");
    XCTAssertEqualObjects([destination deliveryPath], @"users/testUser", @"Single user destination delivery path should be 'users/testUser'");
}

- (void)test_multipleUsers {
    ApigeeAPSDestination* destination = [ApigeeAPSDestination destinationMultipleUsers:@[@"testUser",@"testUser2"]];
    XCTAssertNotNil(destination,@"Multiple users destination should not be nil.");
    XCTAssertEqualObjects([destination deliveryPath], @"users/testUser;testUser2", @"Multiple users destination delivery path should be 'users/testUser;testUser2'");
}

- (void)test_singleGroup {
    ApigeeAPSDestination* destination = [ApigeeAPSDestination destinationSingleGroup:@"testGroup"];
    XCTAssertNotNil(destination,@"Single group destination should not be nil.");
    XCTAssertEqualObjects([destination deliveryPath], @"groups/testGroup", @"Single group destination delivery path should be 'groups/testGroup'");
}

- (void)test_multipleGroups {
    ApigeeAPSDestination* destination = [ApigeeAPSDestination destinationMultipleGroups:@[@"testGroup",@"testGroup2"]];
    XCTAssertNotNil(destination,@"Multiple groups destination should not be nil.");
    XCTAssertEqualObjects([destination deliveryPath], @"groups/testGroup;testGroup2", @"Multiple groups destination delivery path should be 'groups/testGroup;testGroup2'");
}

@end
