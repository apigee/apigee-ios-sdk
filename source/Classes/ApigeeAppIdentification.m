//
//  ApigeeAppIdentification.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeAppIdentification.h"
#import "ApigeeDataClient.h"

@implementation ApigeeAppIdentification

@synthesize organizationId=_organizationId;
@synthesize applicationId=_applicationId;
@synthesize organizationUUID=_organizationUUID;
@synthesize applicationUUID=_applicationUUID;
@synthesize baseURL=_baseURL;

- (id)initWithOrganizationId:(NSString*)theOrganizationId
               applicationId:(NSString*)theApplicationId
{
    self = [super init];
    if( self ) {
        self.organizationId = theOrganizationId;
        self.applicationId = theApplicationId;
        self.baseURL = [ApigeeDataClient defaultBaseURL];
    }
    
    return self;
}

- (id)initWithOrganizationUUID:(NSString*)theOrganizationUUID
               applicationUUID:(NSString*)theApplicationUUID
{
    self = [super init];
    if( self ) {
        self.organizationUUID = theOrganizationUUID;
        self.applicationUUID = theApplicationUUID;
        self.baseURL = [ApigeeDataClient defaultBaseURL];
    }
    
    return self;
}

- (NSString*)uniqueIdentifier {
    NSString* uniqueIdentifier = nil;
    
    if( ([_organizationUUID length] > 0) && ([_applicationUUID length] > 0) ) {
        uniqueIdentifier = [NSString stringWithFormat:@"%@_%@",
                            _organizationUUID,
                            _applicationUUID];
    } else if( ([_organizationId length] > 0) && ([_applicationId length] > 0) ) {
        uniqueIdentifier = [NSString stringWithFormat:@"%@_%@",
                            _organizationId,
                            _applicationId];
    }
    
    return uniqueIdentifier;
}

- (NSString*) organizationId {
    return _organizationId;
}

- (NSString*) applicationId {
    return _applicationId;
}
@end
