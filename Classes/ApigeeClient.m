//
//  ApigeeClient.m
//  ApigeeiOSSDK
//
//  Created by Paul Dardeau on 4/17/13.
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeClient.h"
#import "ApigeeAppIdentification.h"
#import "ApigeeDataClient.h"
#import "ApigeeMonitoringClient.h"
#import "ApigeeMonitoringOptions.h"
#import "ApigeeDefaultiOSLog.h"

@implementation ApigeeClient

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
{
    self = [super init];
    if( self )
    {
        _appIdentification =
            [[ApigeeAppIdentification alloc] initWithOrganizationId:organizationId
                                                      applicationId:applicationId];
        
        _dataClient = [[ApigeeDataClient alloc] initWithOrganizationId:organizationId
                                                     withApplicationID:applicationId];
        
        _monitoringClient = nil;
        /*
        if( _dataClient ) {
            _monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:_appIdentification
                                                                   dataClient:_dataClient];
        } else {
            //[ApigeeDataClient setLogger:[[ApigeeDefaultiOSLog alloc] init]];
        }
         */
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
        _appIdentification =
        [[ApigeeAppIdentification alloc] initWithOrganizationId:organizationId
                                                  applicationId:applicationId];
        _appIdentification.baseURL = baseURL;
        
        _dataClient = [[ApigeeDataClient alloc] initWithOrganizationId:organizationId
                                                     withApplicationID:applicationId
                                                               baseURL:baseURL];
        
        _monitoringClient = nil;
        /*
        if( _dataClient ) {
            _monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:_appIdentification
                                                                   dataClient:_dataClient];
        } else {
            //[ApigeeDataClient setLogger:[[ApigeeDefaultiOSLog alloc] init]];
        }
         */
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
        _appIdentification =
        [[ApigeeAppIdentification alloc] initWithOrganizationId:organizationId
                                                  applicationId:applicationId];
        
        _dataClient = [[ApigeeDataClient alloc] initWithOrganizationId:organizationId
                                                     withApplicationID:applicationId];
        
        if( _dataClient ) {
            _monitoringClient = nil;
            /*
            if( monitoringOptions != nil ) {
                if( monitoringOptions.monitoringEnabled ) {
                    _monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:_appIdentification
                                                                                       dataClient:_dataClient
                                                                                          options:monitoringOptions];
                } else {
                    _monitoringClient = nil;
                }
            } else {
                _monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:_appIdentification
                                                                                   dataClient:_dataClient];
            }
             */
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
        _appIdentification =
        [[ApigeeAppIdentification alloc] initWithOrganizationId:organizationId
                                                  applicationId:applicationId];
        _appIdentification.baseURL = baseURL;

        
        _dataClient = [[ApigeeDataClient alloc] initWithOrganizationId:organizationId
                                                     withApplicationID:applicationId
                                                               baseURL:baseURL];
        
        if( _dataClient ) {
            _monitoringClient = nil;
            /*
            if( monitoringOptions != nil ) {
                if( monitoringOptions.monitoringEnabled ) {
                    _monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:_appIdentification
                                                                                       dataClient:_dataClient
                                                                                          options:monitoringOptions];
                } else {
                    _monitoringClient = nil;
                }
            } else {
                _monitoringClient = [[ApigeeMonitoringClient alloc] initWithAppIdentification:_appIdentification
                                                                                   dataClient:_dataClient];
            }
             */
        } else {
            //[ApigeeDataClient setLogger:[[ApigeeDefaultiOSLog alloc] init]];
        }
    }
    
    return self;
}


- (ApigeeDataClient*)dataClient
{
    return _dataClient;
}

- (ApigeeMonitoringClient*)monitoringClient
{
    return _monitoringClient;
}

- (ApigeeAppIdentification*)appIdentification
{
    return _appIdentification;
}

- (NSString*)loggedInUser
{
    return _loggedInUser;
}

@end
