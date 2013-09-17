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
    return [self initWithOrganizationId:organizationId
                          applicationId:applicationId
                                baseURL:nil
                                options:nil];
}

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     baseURL:(NSString*)baseURL
{
    return [self initWithOrganizationId:organizationId
                          applicationId:applicationId
                                baseURL:baseURL
                                options:nil];
}

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     options:(ApigeeMonitoringOptions*)monitoringOptions
{
    return [self initWithOrganizationId:organizationId
                          applicationId:applicationId
                                baseURL:nil
                                options:monitoringOptions];
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
        
        if( [baseURL length] > 0 ) {
            self.appIdentification.baseURL = baseURL;
        } else {
            self.appIdentification.baseURL = [ApigeeDataClient defaultBaseURL];
        }
        
        self.dataClient = [[ApigeeDataClient alloc] initWithOrganizationId:organizationId
                                                     withApplicationID:applicationId
                                                               baseURL:baseURL];
        
        if( self.dataClient ) {
            NSLog( @"apigee: dataClient created" );
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
            
            if( self.monitoringClient ) {
                NSLog( @"apigee: monitoringClient created" );
            } else {
                NSLog( @"apigee: unable to create monitoringClient" );
            }
        } else {
            NSLog( @"apigee: unable to create dataClient" );
            NSLog( @"apigee: no monitoringClient will be created" );
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
