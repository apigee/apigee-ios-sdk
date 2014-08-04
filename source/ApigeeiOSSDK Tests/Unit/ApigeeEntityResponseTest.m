//
//  ApigeeEntityRequestTest.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 7/31/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Apigee.h"
#import "ApigeeClientResponse.h"

/*!
 @class ApigeeEntityRequestTest
 @abstract The ApigeeEntityRequestTest test case is used to test the validity of various parts of a sample entity request operation.
 */
@interface ApigeeEntityRequestTest : XCTestCase

@property (nonatomic,strong) ApigeeDataClient* dummyDataClient;
@property (nonatomic,strong) ApigeeClientResponse* clientResponse;

@end

@implementation ApigeeEntityRequestTest

- (void)setUp {

    [super setUp];

    NSString* configPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SampleData/apigeeEntityRequest.json" ofType:nil];

    NSData* configData = [NSData dataWithContentsOfFile:configPath];
    NSString* configJSONString = [[NSString alloc] initWithData:configData
                                                       encoding:NSUTF8StringEncoding];

    self.dummyDataClient = [[ApigeeDataClient alloc] initWithOrganizationId:@"test" withApplicationID:@"test"];
    self.clientResponse = [[ApigeeClientResponse alloc] initWithDataClient:self.dummyDataClient];
    [self.clientResponse parse:configJSONString];
}

- (void)tearDown {

    self.dummyDataClient = nil;
    self.clientResponse = nil;

    [super tearDown];
}

/*!
 @abstract Tests the top level properties of the sample data (everything but the entites) for validity.
 */
- (void)test_sampleTopLevelProperties {

    // Missing properties: applicationName/application, duration, count

    ApigeeClientResponse* response = self.clientResponse;

    XCTAssertNotNil(response, @"response should not be nil.");

    XCTAssertEqual(response.timestamp, 1405539157157, @"timestamp should be 1405539157157");
    XCTAssertEqual(response.entityCount, 5, @"entityCount should be 5");
    XCTAssertEqual(response.params.count, 0, @"params.count should be 0");

    XCTAssertEqualObjects(response.action, @"get", @"action should be \"get\"");
    XCTAssertEqualObjects(response.organization, @"rwalsh", @"organization should be \"rwalsh\"");
    XCTAssertEqualObjects(response.application, @"sdk.demo", @"application should be \"sdk.demo\"");
    XCTAssertEqualObjects(response.path, @"/publicevents", @"application should be \"/publicevents\"");
    XCTAssertEqualObjects(response.uri, @"https://api.usergrid.com/rwalsh/sdk.demo/publicevents", @"application should be \"https://api.usergrid.com/rwalsh/sdk.demo/publicevents\"");
}


/*!
 @abstract Tests the first entity of the sample data for validity.
 */
- (void)test_sampleFirstEntityData {

    ApigeeClientResponse* response = self.clientResponse;
    XCTAssertNotNil(response, @"response should not be nil.");

    ApigeeEntity* firstEntity = [response firstEntity];

    XCTAssertNotNil(firstEntity, @"firstEntity should not be nil.");
    XCTAssertEqualObjects(firstEntity, [[response entities] firstObject], @"firstEntity and firstObject in entities list should be the same.");

    XCTAssertEqualObjects(firstEntity.uuid,@"fa015eaa-fe1c-11e3-b94b-63b29addea01",@"uuid is not equal.");
    XCTAssertEqualObjects(firstEntity.type,@"publicevent",@"type should be publicevent.");

    XCTAssertEqualObjects([firstEntity getStringProperty:@"eventName"], @"public event 1", @"eventName is %@ should be public event 1.",[firstEntity getStringProperty:@"eventName"]);

    NSDictionary* locationObject = (NSDictionary*)[firstEntity getObjectProperty:@"location"];
    NSNumber* latitude = locationObject[@"latitude"];
    NSNumber* longitude = locationObject[@"longitude"];
    XCTAssertEqualObjects(latitude,[NSNumber numberWithDouble:33.748995],@"latitude should be 33.748995.");
    XCTAssertEqualObjects(longitude,[NSNumber numberWithDouble:-84.387982],@"longitude should be -84.387982.");
}


@end
