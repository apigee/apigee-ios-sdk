//
//  ApigeeClient.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeClient.h"
#import "ApigeeAppIdentification.h"
#import "ApigeeDataClient.h"
#import "ApigeeMonitoringClient.h"
#import "ApigeeMonitoringOptions.h"
#import "ApigeeDefaultiOSLog.h"

static NSString* kSDKVersion = @"2.0.2-SNAPSHOT";


@interface ApigeeClient ()

@property (strong, nonatomic) ApigeeDataClient* dataClient;
@property (strong, nonatomic) ApigeeMonitoringClient* monitoringClient;
@property (strong, nonatomic) ApigeeAppIdentification* appIdentification;
@property (copy, nonatomic)   NSString* loggedInUser;

@end


@implementation ApigeeClient

@synthesize dataClient;
@synthesize monitoringClient;
@synthesize appIdentification;
@synthesize loggedInUser;

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
{
    self = [super init];
    if( self )
    {
        self.appIdentification =
            [[ApigeeAppIdentification alloc] initWithOrganizationId:organizationId
                                                      applicationId:applicationId];
        
        self.dataClient = [[ApigeeDataClient alloc] initWithOrganizationId:organizationId
                                                     withApplicationID:applicationId];
        
        if( self.dataClient ) {
            self.monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:self.appIdentification
                                                                   dataClient:self.dataClient];
        } else {
            //[ApigeeDataClient setLogger:[[ApigeeDefaultiOSLog alloc] init]];
        }
    }
    
    return self;
}

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     baseURL:(NSString*)baseURL
{
    self = [super init];
    if( self )
    {
        self.appIdentification =
        [[ApigeeAppIdentification alloc] initWithOrganizationId:organizationId
                                                  applicationId:applicationId];
        self.appIdentification.baseURL = baseURL;
        
        self.dataClient = [[ApigeeDataClient alloc] initWithOrganizationId:organizationId
                                                     withApplicationID:applicationId
                                                               baseURL:baseURL];
        
        if( self.dataClient ) {
            self.monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:self.appIdentification
                                                                   dataClient:self.dataClient];
        } else {
            //[ApigeeDataClient setLogger:[[ApigeeDefaultiOSLog alloc] init]];
        }
    }
    
    return self;
}

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     options:(ApigeeMonitoringOptions*)monitoringOptions
{
    self = [super init];
    if( self )
    {
        self.appIdentification =
        [[ApigeeAppIdentification alloc] initWithOrganizationId:organizationId
                                                  applicationId:applicationId];
        
        self.dataClient = [[ApigeeDataClient alloc] initWithOrganizationId:organizationId
                                                     withApplicationID:applicationId];
        
        if( self.dataClient ) {
            if( monitoringOptions != nil ) {
                if( monitoringOptions.monitoringEnabled ) {
                    self.monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:self.appIdentification
                                                                                       dataClient:self.dataClient
                                                                                          options:monitoringOptions];
                } else {
                    self.monitoringClient = nil;
                }
            } else {
                self.monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:self.appIdentification
                                                                                   dataClient:self.dataClient];
            }
        } else {
            //[ApigeeDataClient setLogger:[[ApigeeDefaultiOSLog alloc] init]];
        }
    }
    
    return self;
}


- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     baseURL:(NSString*)baseURL
                     options:(ApigeeMonitoringOptions*)monitoringOptions
{
    self = [super init];
    if( self )
    {
        self.appIdentification =
        [[ApigeeAppIdentification alloc] initWithOrganizationId:organizationId
                                                  applicationId:applicationId];
        self.appIdentification.baseURL = baseURL;

        
        self.dataClient = [[ApigeeDataClient alloc] initWithOrganizationId:organizationId
                                                     withApplicationID:applicationId
                                                               baseURL:baseURL];
        
        if( self.dataClient ) {
            if( monitoringOptions != nil ) {
                if( monitoringOptions.monitoringEnabled ) {
                    self.monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:self.appIdentification
                                                                                       dataClient:self.dataClient
                                                                                          options:monitoringOptions];
                } else {
                    self.monitoringClient = nil;
                }
            } else {
                self.monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:self.appIdentification
                                                                                   dataClient:self.dataClient];
            }
        } else {
            //[ApigeeDataClient setLogger:[[ApigeeDefaultiOSLog alloc] init]];
        }
    }
    
    return self;
}


+ (NSString*)sdkVersion
{
    return kSDKVersion;
}

@end
