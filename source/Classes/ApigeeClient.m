/*
 * Copyright 2014 Apigee Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ApigeeClient.h"
#import "ApigeeAppIdentification.h"
#import "ApigeeDataClient.h"
#import "ApigeeMonitoringClient.h"
#import "ApigeeMonitoringOptions.h"
#import "ApigeeDefaultiOSLog.h"

/*!
 @version 2.0.20
 */
static NSString* kSDKVersion = @"2.0.20";


@interface ApigeeClient ()

@property (strong, nonatomic) ApigeeDataClient* dataClient;
@property (strong, nonatomic) ApigeeMonitoringClient* monitoringClient;
@property (strong, nonatomic) ApigeeAppIdentification* appIdentification;

@end


@implementation ApigeeClient

@synthesize dataClient;
@synthesize monitoringClient;
@synthesize appIdentification;

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
{
    return [self initWithOrganizationId:organizationId
                          applicationId:applicationId
                                baseURL:nil
                               urlTerms:nil
                                options:nil];
}

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     baseURL:(NSString*)baseURL
{
    return [self initWithOrganizationId:organizationId
                          applicationId:applicationId
                                baseURL:baseURL
                               urlTerms:nil
                                options:nil];
}

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     baseURL:(NSString*)baseURL
                     options:(ApigeeMonitoringOptions*)monitoringOptions
{
    return [self initWithOrganizationId:organizationId
                          applicationId:applicationId
                                baseURL:baseURL
                               urlTerms:nil
                                options:monitoringOptions];
    
}


- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     baseURL:(NSString*)baseURL
                     urlTerms:(NSString*)urlTerms
{
    return [self initWithOrganizationId:organizationId
                          applicationId:applicationId
                                baseURL:baseURL
                               urlTerms:urlTerms
                                options:nil];
}

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     options:(ApigeeMonitoringOptions*)monitoringOptions
{
    return [self initWithOrganizationId:organizationId
                          applicationId:applicationId
                                baseURL:nil
                                urlTerms:nil
                                options:monitoringOptions];
}

- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId
                     baseURL:(NSString*)baseURL
                     urlTerms:(NSString*)urlTerms
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
                                                                       baseURL:baseURL
                                                                       urlTerms:urlTerms];
        
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
                self.monitoringClient =
                    [[ApigeeMonitoringClient alloc] initWithAppIdentification:self.appIdentification
                                                                   dataClient:self.dataClient];
            }
            
            if( self.monitoringClient ) {
                NSLog( @"apigee: monitoringClient created" );
            } else {
                if (monitoringOptions && monitoringOptions.monitoringEnabled) {
                    NSLog( @"apigee: unable to create monitoringClient" );
                }
            }
        } else {
            NSLog( @"apigee: unable to create dataClient" );
            NSLog( @"apigee: no monitoringClient will be created" );
        }
        
        [ApigeeDataClient setLogger:[[ApigeeDefaultiOSLog alloc] init]];
    }
    
    return self;
}


+ (NSString*)sdkVersion
{
    return kSDKVersion;
}

@end
