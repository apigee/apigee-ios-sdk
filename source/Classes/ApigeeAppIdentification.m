/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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

- (NSString*) baseURL {
    return _baseURL;
}

- (NSString*) applicationUUID {
    return _applicationUUID;
}

- (NSString*) organizationUUID {
    return _organizationUUID;
}

@end
