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

#import <Foundation/Foundation.h>

/*!
 @class ApigeeAppIdentification
 @abstract The ApigeeAppIdentification class contains various fields that are
    used by the application when talking with the server
 */
@interface ApigeeAppIdentification : NSObject
{
    NSString* _organizationId;
    NSString* _applicationId;
    NSString* _organizationUUID;
    NSString* _applicationUUID;
    NSString* _baseURL;
}

/*!
 @property organizationId
 @abstract The identifier used by Apigee to uniquely identify the organization
 */
@property (copy,nonatomic) NSString* organizationId;

/*!
 @property applicationId
 @abstract The identifier used by Apigee to uniquely identify the application
 */
@property (copy,nonatomic) NSString* applicationId;

/*!
 @property organizationUUID
 @abstract The UUID used by Apigee to uniquely identify the organization
 */
@property (copy,nonatomic) NSString* organizationUUID;

/*!
 @property applicationUUID
 @abstract The UUID used by Apigee to uniquely identify the application
 */
@property (copy,nonatomic) NSString* applicationUUID;

/*!
 @property baseURL
 @abstract The URL used for server communications
 */
@property (copy,nonatomic) NSString* baseURL;


/*!
 @abstract Initializes an ApigeeAppIdentification instance using identifier
    values for organization and application
 @param organizationId the identifier for the organization
 @param applicationId the identifier for the application
 */
- (id)initWithOrganizationId:(NSString*)organizationId
               applicationId:(NSString*)applicationId;

/*!
 @abstract Initializes an ApigeeAppIdentification instance using UUID values
    for organization and application
 @param organizationUUID the UUID for the organization
 @param applicationUUID the UUID for the application
 */
- (id)initWithOrganizationUUID:(NSString*)organizationUUID
               applicationUUID:(NSString*)applicationUUID;

/*!
 @abstract Retrieves unique identifier for app within org
 @return unique identifier as string
 */
- (NSString*)uniqueIdentifier;

/*!
 @abstract Retrieves organization ID for current application
 @return organization Id
 */
- (NSString*) organizationId;

/*!
 @abstract Retrieves application ID within org
 @return application Id
 */
- (NSString*) applicationId;

/*!
 @abstract Retrieves application UUID within org
 @return application UUID
 */
- (NSString*) applicationUUID;

/*!
 @abstract Retrieves organization UUID for current application
 @return organization UUID
 */
- (NSString*) organizationUUID;

/*!
 @abstract Retrieves base URL for monitoring client calls
 @return the base url, usually https://api.usergrid.com
 */
- (NSString*) baseURL;

@end
