//
//  ApigeeCollectionTests.m
//  ApigeeiOSSDK
//
//  Created by Robert Walsh on 11/17/14.
//  Copyright (c) 2014 Apigee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Apigee.h"
#import "ApigeeIntegrationTestsConstants.h"
#import "ApigeeMonitoringOptions.h"

/*!
 @class ApigeeCollectionTests
 @abstract The ApigeeCollectionTests test case is used to the functionality of the ApigeeCollection class.
 */

@interface NSURLRequest (ApplePrivate)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@interface ApigeeCollectionTests : XCTestCase

@end

@implementation ApigeeCollectionTests

-(BOOL)continueAfterFailure {
    return YES;
}

- (void)setUp {
    [super setUp];

    // This is a workaround for integration tests running with xctool/travis-ci.
    // Without this it always reports that retrieving config from server: The certificate for this server is invalid.
    // More info can be found here http://quellish.tumblr.com/post/33284931593/ssl-connections-from-an-ocunit-test-failing.
    
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES
                                       forHost:kAPIApigeeServer];
}

- (void)tearDown {
    [super tearDown];
}

/*!
 @abstract Tests creating a new ApigeeCollection.
 */
- (void)test_CreatingCollection {
    ApigeeMonitoringOptions* options = [[ApigeeMonitoringOptions alloc] init];
    [options setMonitoringEnabled:NO];

    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName applicationId:kAPIAppID options:options];
    ApigeeDataClient* dataClient = [apigeeClient dataClient];

    ApigeeCollection *collection = [[ApigeeCollection alloc] init:dataClient type:kAPICollectionTestCollectionName qs:nil];
    XCTAssertNotNil(collection,@"creation of collection manually should not be nil.");
}

/*!
 @abstract Tests the flow of paging in the ApigeeCollection class.
 */
- (void)test_CollectionEntityPaging {

    ApigeeMonitoringOptions* options = [[ApigeeMonitoringOptions alloc] init];
    [options setMonitoringEnabled:NO];

    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName applicationId:kAPIAppID options:options];
    ApigeeDataClient* dataClient = [apigeeClient dataClient];

    // Create the collection with the dataClient and a query with a limit of 10 entities.
    ApigeeCollection *collection = [[ApigeeCollection alloc] init:dataClient type:kAPICollectionTestCollectionName query:[[ApigeeQuery alloc] init]];
    [[collection query] setLimit:10];

    XCTAssertNotNil(collection,@"creation of collection manually should not be nil.");
    XCTAssertNil([collection getFirstEntity],@"collection should have no entities yet.");

    // Add 20 different entities.
    for( int i = 0; i < 20; i++ ) {
        NSDictionary* testEntityDictionary = @{@"title" : [NSString stringWithFormat:@"testEntity%i",i+1],
                                               @"type"  : kAPICollectionTestCollectionName};
        [collection addEntity:testEntityDictionary];
    }

    XCTAssertEqual([[collection list] count], 20, @"Collection should now have 20 entities");

    // Perform a fetch so we make sure that it was actually added to the server.
    ApigeeClientResponse *fetchResponse = [collection fetch];
    XCTAssertTrue([fetchResponse completedSuccessfully],@"Fetching the entites should have completed successfully");

    NSArray* first_10_Entities = [[collection list] copy];
    XCTAssertEqual([first_10_Entities count], 10, @"first_10_Entities should have 10 entities");

    // Page to the next 10 entities
    ApigeeClientResponse* getNextPageResponse = [collection getNextPage];
    XCTAssertTrue([getNextPageResponse completedSuccessfully],@"Getting the next 10 entites should have completed successfully");

    NSArray* next_10_Entities = [[collection list] copy];
    XCTAssertEqual([next_10_Entities count], 10, @"next_10_Entities should have 10 entities");

    ApigeeEntity* firstEntityInFirstList = [first_10_Entities firstObject];
    ApigeeEntity* firstEntityInNextList = [next_10_Entities firstObject];

    XCTAssertNotNil(firstEntityInFirstList,@"firstEntityInFirstList should not be nil.");
    XCTAssertNotNil(firstEntityInNextList,@"firstEntityInNextList should not be nil.");

    XCTAssertEqualObjects([firstEntityInFirstList type], [firstEntityInNextList type],@"entities should have the same types");
    XCTAssertNotEqualObjects([firstEntityInFirstList getStringProperty:@"title"], [firstEntityInNextList getStringProperty:@"title"],@"entities should have different titles");
    XCTAssertEqualObjects([firstEntityInFirstList getStringProperty:@"title"], @"testEntity1",@"firstEntityInFirstList should have the title 'testEntity1'");
    XCTAssertEqualObjects([firstEntityInNextList getStringProperty:@"title"], @"testEntity11",@"firstEntityInNextList should have the the title 'testEntity11'");

    // Create the delete URL manually.
    NSMutableString* deleteRequestURL = [[NSMutableString alloc] initWithString:@"https://api.usergrid.com/"];
    [deleteRequestURL appendFormat:@"%@/%@/",kAPIOrgName,kAPIAppID];
    [deleteRequestURL appendFormat:@"%@/",kAPICollectionTestCollectionName];
    [deleteRequestURL appendString:@"?limit=20"];

    // Delete all 20 entities.
    ApigeeClientResponse *deleteResponse = [dataClient apiRequest:deleteRequestURL
                                                        operation:@"DELETE"
                                                             data:nil];

    // Make sure the deleteResponse completed successfully.
    XCTAssertTrue([deleteResponse completedSuccessfully],@"delete response should have completed successfully");
}

/*!
 @abstract Tests the flow of adding, fetching and deleting of entities in the ApigeeCollection class.
 */
- (void)test_AddingAndDeletingEntitiesInCollection {

    ApigeeMonitoringOptions* options = [[ApigeeMonitoringOptions alloc] init];
    [options setMonitoringEnabled:NO];

    ApigeeClient* apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:kAPIOrgName applicationId:kAPIAppID options:options];
    ApigeeDataClient* dataClient = [apigeeClient dataClient];

    // Create the collection with the dataClient and a query with a limit of 20 entities.
    ApigeeCollection *collection = [[ApigeeCollection alloc] init:dataClient type:kAPICollectionTestCollectionName query:[[ApigeeQuery alloc] init]];
    [[collection query] setLimit:20];

    XCTAssertNotNil(collection,@"creation of collection manually should not be nil.");
    XCTAssertNil([collection getFirstEntity],@"collection should have no entities yet.");

    // Add 20 different entities.
    for( int i = 0; i < 20; i++ ) {
        NSDictionary* testEntityDictionary = @{@"title" : [NSString stringWithFormat:@"testEntity%i",i+1],
                                               @"type"  : kAPICollectionTestCollectionName};
        [collection addEntity:testEntityDictionary];
    }

    // Perform a fetch so we make sure that it was actually added to the server.  Should return all 20.
    ApigeeClientResponse *fetchResponse = [collection fetch];
    XCTAssertTrue([fetchResponse completedSuccessfully],@"fetching the entites should have completed successfully");
    XCTAssertEqual([[collection list] count], 20, @"collection should now have 20 entities");

    // Create the delete URL manually.
    NSMutableString* deleteRequestURL = [[NSMutableString alloc] initWithString:@"https://api.usergrid.com/"];
    [deleteRequestURL appendFormat:@"%@/%@/",kAPIOrgName,kAPIAppID];
    [deleteRequestURL appendFormat:@"%@/",kAPICollectionTestCollectionName];
    [deleteRequestURL appendString:@"?limit=20"];

    // Delete all 20 entities.
    ApigeeClientResponse *deleteResponse = [dataClient apiRequest:deleteRequestURL
                                                        operation:@"DELETE"
                                                             data:nil];

    // Make sure the deleteResponse completed successfully.
    XCTAssertTrue([deleteResponse completedSuccessfully],@"delete response should have completed successfully");

    // Fetch and asset that there are no entities left in the collection.
    fetchResponse = [collection fetch];
    XCTAssertTrue([fetchResponse completedSuccessfully],@"fetching the entites should have completed successfully");
    XCTAssertEqual([[collection list] count], 0, @"collection should now have 0 entities");
}

@end
