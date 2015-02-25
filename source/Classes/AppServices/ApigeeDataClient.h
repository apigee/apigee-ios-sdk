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
#import <UIKit/UIKit.h>
#import "ApigeeClientResponse.h"
#import "ApigeeClientDelegate.h"
#import "ApigeeQuery.h"
#import "ApigeeActivity.h"
#import "ApigeeUser.h"
#import "ApigeeLogging.h"

/******************** A WORD ON NETWORK COMMUNICATION CALLS ****************
Some calls require network communication with Usergrid. Therefore,
they all have the option of being synchronous (blocking) or asynchronous.

You may specify an asynchronous delegate with the call setDelegate. If you
do, all calls will be asynchronous and responses will be sent to that delegate. 
The immediate return value (a ApigeeClientResponse *) from any call will have its
transactionState set to kApigeeClientResponsePending, and the transactionID will be
properly set (allowing you to identify the specific call in your callback if you
wish.)
 
The delegate must support the following message:
-(void)ApigeeClientResponse:(ApigeeClientResponse *)response

If you do not set a delegate, all functions will run synchronously, blocking 
until a response has been received or an error detected. 
****************************************************************************/


/**************************** A WORD ON ApigeeQUERY *****************************
Some calls take a ApigeeQuery *. These are functions that return a lot of data, as 
opposed to a simple answer. You may use the ApigeeQuery to control the data with filters
and response limits. See ApigeeQuery.h for more information.

In all cases, where a ApigeeQuery is one of the parameters, you may send nil. If you
do, the query will be completely unfiltered, and you will receive back *all* the data
associated with the operation, up to the response limit, which is 10. You can
set the response limit in ApigeeQuery as well. 
****************************************************************************/

@class ApigeeCollection;
@class ApigeeAPSPayload;
@class ApigeeAPSDestination;
@class ApigeeCounterIncrement;

typedef void (^ApigeeDataClientCompletionHandler)(ApigeeClientResponse *response);
typedef void (^ApigeeOAuth2CompletionHandler)(NSString *accessToken, NSString* refreshToken, NSError* error);

/*!
 @class ApigeeDataClient
 @abstract Top-level class for interfacing with Usergrid and server-side data
    functionality
 */
@interface ApigeeDataClient : NSObject

//******************************************************************************
/*!
 @methodgroup Class-Level Accessor Methods
 */
/*!
 @abstract Retrieves version string for the Usergrid client (ApigeeDataClient)
 @return string value with version information
 */
+(NSString *) version;

/*!
 @abstract Retrieves the default base URL that is used for server communications
    when an override value is not given
 @return string value for the default base URL
 */
+(NSString*)defaultBaseURL;

/********************* INIT AND SETUP *********************/
/*!
 @methodgroup Initialization and Setup Methods
 */
/*!
 @abstract Initialize with an org ID and app ID
 @param organizationID the org name associated with the app
 @param applicationID the app name associated with the app
 */
-(id) initWithOrganizationId:(NSString *)organizationID
           withApplicationID:(NSString *)applicationID;

/*!
 @abstract Initialize with an org ID, app ID, and a base Usergrid URL
 @param organizationID the org name associated with the app
 @param applicationID the app name associated with the app
 @param baseURL the base Usergrid URL to use for server communications
 @param urlTerms default string of URL params to append to all API calls
 @discussion This is useful if you are running a local Apigee server or your
    company has its own public Apigee server. The default URL is https://api.usergrid.com.
    The base URL must be a fully formatted http link, including the "http://"
    or "https://" at the beginning.
 */
-(id) initWithOrganizationId:(NSString *)organizationID
           withApplicationID:(NSString *)applicationID
                     baseURL:(NSString *)baseURL
                     urlTerms:(NSString*)urlTerms;

// set the delegate. See "A WORD ON NETWORK COMMUNICATION CALLS"
// at the top of the file for a detailed explanation.
/*!
 @abstract Sets the delegate to be used for callbacks when server requests complete
 @param delegate The delegate that will be called, nil to have no delegate
 @return boolean indicating whether the new delegate value has been set
 @discussion You may change the delegate at any time, but be forewarned that any
    pending transactions in progress will be abandoned. Changing the delegate
    (especially setting it to nil) ensures that the previous delegate will
    receive no further messages from this instance of ApigeeClient. Setting the
    delegate to nil puts the API into synchronous mode.

    The function will return NO if the delegate is rejected. This means
    the delegate does not support the required delegation function
    "ApigeeClientResponse".
 @textblock
 This is the formal declaration of ApigeeClientResponse:
    -(void)ApigeeClientResponse:(ApigeeClientResponse *)response
 @/textblock
 @see ApigeeClientDelegate ApigeeClientDelegate
 */
-(BOOL) setDelegate:(id<ApigeeClientDelegate>)delegate;

/********************* PERMISSIONS / ROLES *********************/
/*!
 @methodgroup Permissions/Roles Methods
 */
/*!
 @abstract Assign the specified permissions to a user or group
 @param permissions The permissions to assign in the format <operation>:<resource_path>, e.g. post:/users
 @param entityID The UUID of the group or user the permissions are being assigned to
 @param entityType Either 'group' or 'user'
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)assignPermissions: (NSString *)permissions toEntity: (NSString *)entityID ofType: (NSString *)entityType;

/*!
 @abstract Assign the specified permissions to a user or group
 @param permissions The permissions to assign in the format <operation>:<resource_path>, e.g. post:/users
 @param entityID The UUID of the group or user the permissions are being assigned to
 @param entityType Either 'group' or 'user'
 @param completionHandler The completion handler to call when complete
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)assignPermissions: (NSString *)permissions toEntity: (NSString *)entityID ofType: (NSString *)entityType
                             completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Remove the specified permissions from a user or group
 @param permissions The permissions to remove in the format <operation>:<resource_path>, e.g. post:/users
 @param entityID The UUID of the group or user the permissions are being removed from
 @param entityType Either 'group' or 'user'
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removePermissions: (NSString *)permissions fromEntity: (NSString *)entityID ofType: (NSString *)entityType;

/*!
 @abstract Remove the specified permissions from a user or group
 @param permissions The permissions to remove in the format <operation>:<resource_path>, e.g. post:/users
 @param entityID The UUID of the group or user the permissions are being removed from
 @param entityType Either 'group' or 'user'
 @param completionHandler The completion handler to call when complete
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removePermissions: (NSString *)permissions fromEntity: (NSString *)entityID ofType: (NSString *)entityType
                             completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;                             

/*!
 @abstract Creates a new role and assigns permissions to it
 @param roleName The name of the new role
 @param permissions The permissions to remove in the format <operation>:<resource_path>, e.g. post:/users 
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)createRole: (NSString *)roleName withPermissions: (NSString *)permissions;

/*!
 @abstract Creates a new role and assigns permissions to it
 @param roleName The name of the new role
 @param permissions The permissions to remove in the format <operation>:<resource_path>, e.g. post:/users
 @param completionHandler The completion handler to call when complete
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)createRole: (NSString *)roleName withPermissions: (NSString *)permissions
                             completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;                             

/*!
 @abstract Assigns a role to a user or group
 @param roleName The name of the new role
 @param entityID The UUID of the group or user the role is being assigned to
 @param entityType Either 'group' or 'user'
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)assignRole: (NSString *)roleName toEntity: (NSString *)entityID ofType: (NSString *)entityType;

/*!
 @abstract Assigns a role to a user or group
 @param roleName The name of the role to be assigned
 @param entityID The UUID of the group or user the role is being assigned to
 @param entityType Either 'group' or 'user'
 @param completionHandler The completion handler to call when complete
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)assignRole: (NSString *)roleName toEntity: (NSString *)entityID ofType: (NSString *)entityType
                             completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Removes a role from a user or group
 @param roleName The name of the role to be removed
 @param entityID The UUID of the group or user the role is being removed from
 @param entityType Either 'group' or 'user'
 @param completionHandler The completion handler to call when complete
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removeRole: (NSString *)roleName fromEntity: (NSString *)entityID ofType: (NSString *)entityType;

/*!
 @abstract Removes a role from a user or group
 @param roleName The name of the role to be removed
 @param entityID The UUID of the group or user the role is being removed from
 @param entityType Either 'group' or 'user'
 @param completionHandler The completion handler to call when complete
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removeRole: (NSString *)roleName fromEntity: (NSString *)entityID ofType: (NSString *)entityType
                             completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/********************* LOGIN / LOGOUT *********************/
/*!
 @methodgroup Login/Logout Methods
 */
/*!
 @abstract Log in with the given username and password
 @param userName The userName for the user
 @param password The password for the user
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)logInUser:(NSString *)userName
                          password:(NSString *)password;

/*!
 @abstract Asynchronous log in with the given username and password
 @param userName The userName for the user
 @param password The password for the user
 @param completionHandler The completion handler to call when complete
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeDataClientCompletionHandler ApigeeDataClientCompletionHandler
 */
-(ApigeeClientResponse *)logInUser:(NSString *)userName
                          password:(NSString *)password
                 completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Log in with the given username and PIN value
 @param userName The userName for the user
 @param pin The pin value for the user
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)logInUserWithPin:(NSString *)userName
                                      pin:(NSString *)pin;

/*!
 @abstract Asynchronous log in with the given username and PIN value
 @param userName The userName for the user
 @param pin The pin value for the user
 @param completionHandler The completion handler to call when complete
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeDataClientCompletionHandler ApigeeDataClientCompletionHandler
 */
-(ApigeeClientResponse *)logInUserWithPin:(NSString *)userName
                                      pin:(NSString *)pin
                        completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Log in user with Facebook token
 @param facebookToken the Facebook token to use for login
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)logInUserWithFacebook:(NSString *)facebookToken;

/*!
 @abstract Asynchronous log in user with Facebook token
 @param facebookToken the Facebook token to use for login
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)logInUserWithFacebook:(NSString *)facebookToken
                             completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Log in as the administrator of the application
 @param adminUserName the user name for the admin
 @param adminSecret the secret for the admin
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion Generally used for applications that have an "administrator" feature.
    Not the sort of thing you want normal users doing.
 */
-(ApigeeClientResponse *)logInAdmin:(NSString *)adminUserName
                             secret:(NSString *)adminSecret;

/*!
 @abstract Asynchronously log in as the administrator of the application
 @param adminUserName the user name for the admin
 @param adminSecret the secret for the admin
 @param completionHandler the completion handler to run at completion
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion Generally used for applications that have an "administrator" feature.
    Not the sort of thing you want normal users doing.
 */
-(ApigeeClientResponse *)logInAdmin:(NSString *)adminUserName
                             secret:(NSString *)adminSecret
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Log out a user and destroy the token in ApigeeDataClient on the server.
 @param username The name identifier for the user being logged out
 @discussion The ApigeeDataClient only supports one user logged in at a time.
    You can have multiple instances of ApigeeDataClient if you want multiple
    users doing transactions simultaneously.
 */
-(void)logOut:(NSString*)username;

/*!
 @abstract Log out a user and destroy a specific token on the server.
 @param username The name identifier for the user being logged out
 @param forToken The access token to be destroyed on the server
 @discussion If the token matches the token in ApigeeDataClient, the token is 
    cleared from the ApigeeDataClient instance. This is useful if you're using 
    tokens to authorize different clients. For example, a user is logged in on
    their mobile device but their web client token needs to be invalidated.
 */
-(void)logOut:(NSString*)username forToken:(NSString*)token;

/*!
 @abstract Log out a user and destroy all tokens associated with the user on the server.
 @param username The name identifier for the user being logged out
 @discussion Also clears out the token in the ApigeeDataClient instance. This is useful 
    if you're using tokens to authorize the user on different clients. For example, 
    a different token for a web client session, mobile client session, etc. This method
    is the equivalent of logging out all clients.
 */
-(void)logOutAllTokens:(NSString*)username;

/********************* USER MANAGEMENT *********************/
/*!
 @methodgroup User Management Methods
 */
/*!
 @abstract Adds a new user
 @param username The name identifier for the user
 @param email The user's email address
 @param name The user's name
 @param password The password for the user
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)addUser:(NSString *)username
                           email:(NSString *)email
                            name:(NSString *)name
                        password:(NSString *)password;

/*!
 @abstract Asynchronously adds a new user
 @param username The name identifier for the user
 @param email The user's email address
 @param name The user's name
 @param password The password for the user
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)addUser:(NSString *)username
                           email:(NSString *)email
                            name:(NSString *)name
                        password:(NSString *)password
               completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Updates a user's password
 @param usernameOrEmail
 @param oldPassword
 @param newPassword
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)updateUserPassword:(NSString *)usernameOrEmail
                                oldPassword:(NSString *)oldPassword
                                newPassword:(NSString *)newPassword;

/*!
 @abstract Asynchronously updates a user's password
 @param usernameOrEmail
 @param oldPassword
 @param newPassword
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)updateUserPassword:(NSString *)usernameOrEmail
                                oldPassword:(NSString *)oldPassword
                                newPassword:(NSString *)newPassword
                          completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get all the groups this user is in
 @param userID The user whose group memberships we're querying
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)getGroupsForUser:(NSString *)userID;

/*!
 @abstract Asynchronously get all the groups this user is in
 @param userID The user whose group memberships we're querying
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)getGroupsForUser:(NSString *)userID
                        completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Retrieve users in this app
 @param query the query to constrain the retrieval
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 @discussion You should strongly consider sending an ApigeeQuery along with this call
 */
-(ApigeeClientResponse *)getUsers:(ApigeeQuery *)query;

/*!
 @abstract Retrieve users in this app
 @param query the query to constrain the retrieval
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 @discussion You should strongly consider sending an ApigeeQuery along with this call
 */
-(ApigeeClientResponse *)getUsers:(ApigeeQuery *)query
                completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/********************* ACTIVITY MANAGEMENT *********************/
/*!
 @methodgroup Activity Management Methods
 */
/*!
 @abstract Create a new activity
 @param activity Dictionary of activity properties
 @return ApigeeClientResponse instance
 @discussion Note that there is a class, ApigeeActivity, which can help you
    create and validate an Activity, and will generate the needed NSDictionary
    for you.
 @seealso ApigeeActivity ApigeeActivity
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)createActivity:(NSDictionary *)activity;

/*!
 @abstract Asynchronously create a new activity
 @param activity Dictionary of activity properties
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @discussion Note that there is a class, ApigeeActivity, which can help you
    create and validate an Activity, and will generate the needed NSDictionary
    for you.
 @seealso ApigeeActivity ApigeeActivity
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)createActivity:(NSDictionary *)activity
                      completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Create an activity and post it to a user in a single step
 @param userID The user who has the activity
 @param activityProperties Dictionary of activity properties
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see createActivity:
 @discussion See comment about createActivity for information on making activity
    creation easier.
 */
-(ApigeeClientResponse *)postUserActivity:(NSString *)userID
                               properties:(NSDictionary *)activityProperties;

/*!
 @abstract Create an activity and post it to a user in a single step
 @param userID The user who has the activity
 @param activity The activity
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see createActivity:
 @discussion See comment about createActivity for information on making activity
 creation easier.
 */
-(ApigeeClientResponse *)postUserActivity:(NSString *)userID
                                 activity:(ApigeeActivity *)activity;

/*!
 @abstract Asynchronously create an activity and post it to a user in a single step
 @param userID The user who has the activity
 @param activityProperties Dictionary of activity properties
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see createActivity:
 @discussion See comment about createActivity for information on making activity
 creation easier.
 */
-(ApigeeClientResponse *)postUserActivity:(NSString *)userID
                               properties:(NSDictionary *)activityProperties
                        completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Asynchronously create an activity and post it to a user in a single step
 @param userID The user who has the activity
 @param activity The activity
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see createActivity:
 @discussion See comment about createActivity for information on making activity
 creation easier.
 */
-(ApigeeClientResponse *)postUserActivity:(NSString *)userID
                                 activity:(ApigeeActivity *)activity
                        completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Post an already-created activity to a user
 @param userID
 @param activityUUID
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)postUserActivityByUUID:(NSString *)userID
                                       activity:(NSString *)activityUUID;

/*!
 @abstract Asynchronously post an already-created activity to a user
 @param userID
 @param activityUUID
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)postUserActivityByUUID:(NSString *)userID
                                       activity:(NSString *)activityUUID
                              completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Create an activity and post it to a group in a single step
 @param groupID The group that has the activity
 @param activityProperties Dictionary of activity properties
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see createActivity:
 @discussion See comment for createActivity for information on making Activity creation easier
 */
-(ApigeeClientResponse *)postGroupActivity:(NSString *)groupID
                                properties:(NSDictionary *)activityProperties;

/*!
 @abstract Create an activity and post it to a group in a single step
 @param groupID The group that has the activity
 @param activity The activity
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see createActivity:
 @discussion See comment for createActivity for information on making Activity creation easier
 */
-(ApigeeClientResponse *)postGroupActivity:(NSString *)groupID
                                  activity:(ApigeeActivity *)activity;

/*!
 @abstract Asynchronously create an activity and post it to a group in a single step
 @param groupID The group that has the activity
 @param activityProperties Dictionary of activity properties
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see createActivity:
 @discussion See comment for createActivity for information on making Activity creation easier
 */
-(ApigeeClientResponse *)postGroupActivity:(NSString *)groupID
                                properties:(NSDictionary *)activityProperties
                         completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Asynchronously create an activity and post it to a group in a single step
 @param groupID The group that has the activity
 @param activity The activity
 @param completionHandler Callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see createActivity:
 @discussion See comment for createActivity for information on making Activity creation easier
 */
-(ApigeeClientResponse *)postGroupActivity:(NSString *)groupID
                                  activity:(ApigeeActivity *)activity
                         completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Post an already-created activity to a group
 @param groupID
 @param activityUUID
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)postGroupActivityByUUID:(NSString *)groupID
                                        activity:(NSString *)activityUUID;

-(ApigeeClientResponse *)postGroupActivityByUUID:(NSString *)groupID
                                        activity:(NSString *)activityUUID
                               completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get the activities this user is in
 @param userID
 @param query
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getActivitiesForUser:(NSString *)userID
                                        query:(ApigeeQuery *)query;

/*!
 @abstract Asynchronously get the activities this user is in
 @param userID
 @param query
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getActivitiesForUser:(NSString *)userID
                                        query:(ApigeeQuery *)query
                            completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get the activities this group is in
 @param groupID
 @param query
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getActivitiesForGroup:(NSString *)groupID
                                         query:(ApigeeQuery *)query;

/*!
 @abstract Asynchronously get the activities this group is in
 @param groupID
 @param query
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getActivitiesForGroup:(NSString *)groupID
                                         query:(ApigeeQuery *)query
                             completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get the activity feed for a user
 @param userID
 @param query
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getActivityFeedForUser:(NSString *)userID
                                          query:(ApigeeQuery *)query;

/*!
 @abstract Asynchronously get the activity feed for a user
 @param userID
 @param query
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getActivityFeedForUser:(NSString *)userID
                                          query:(ApigeeQuery *)query
                              completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get the activity feed for a group
 @param groupID
 @param query
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getActivityFeedForGroup:(NSString *)groupID
                                           query:(ApigeeQuery *)query;

/*!
 @abstract Asynchronously get the activity feed for a group
 @param groupID
 @param query
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getActivityFeedForGroup:(NSString *)groupID
                                           query:(ApigeeQuery *)query
                               completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Remove an activity
 @param activityUUID
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removeActivity:(NSString *)activityUUID;

/*!
 @abstract Asynchronously remove an activity
 @param activityUUID
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removeActivity:(NSString *)activityUUID
                      completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/********************* GROUP MANAGEMENT *********************/
/*!
 @methodgroup Group Management Methods
 */
/*!
 @abstract Create a new group
 @param groupPath The path for the new group
 @param groupTitle Title for group (optional, may be nil)
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion The groupPath can be a path with slashes to make for a hierarchical
    structure of your own design (if you want).
 */
-(ApigeeClientResponse *)createGroup:(NSString *)groupPath
                          groupTitle:(NSString *)groupTitle;

/*!
 @abstract Asynchronously create a new group
 @param groupPath The path for the new group
 @param groupTitle Title for group (optional, may be nil)
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion The groupPath can be a path with slashes to make for a hierarchical
 structure of your own design (if you want).
 */
-(ApigeeClientResponse *)createGroup:(NSString *)groupPath
                          groupTitle:(NSString *)groupTitle
                   completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Add a user to a group
 @param userID The identifier of the user to add
 @param groupID The identifier of the group the user will be added to
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)addUserToGroup:(NSString *)userID
                                  group:(NSString *)groupID;

/*!
 @abstract Asynchronously add a user to a group
 @param userID
 @param groupID
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)addUserToGroup:(NSString *)userID
                                  group:(NSString *)groupID
                      completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Remove a user from a group
 @param userID
 @param groupID
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removeUserFromGroup:(NSString *)userID
                                       group:(NSString *)groupID;

/*!
 @abstract Asynchronously remove a user from a group
 @param userID
 @param groupID
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removeUserFromGroup:(NSString *)userID
                                       group:(NSString *)groupID
                           completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get all the users in this group
 @param groupID
 @param query
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getUsersForGroup:(NSString *)groupID
                                    query:(ApigeeQuery *)query;

/*!
 @abstract Asynchronously get all the users in this group
 @param groupID
 @param query
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getUsersForGroup:(NSString *)groupID
                                    query:(ApigeeQuery *)query
                        completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;


/******************** ENTITY MANAGEMENT ********************/
/*!
 @methodgroup Entity Management Methods
 */
/*!
 @abstract Adds an entity to the specified collection
 @param newEntity Dictionary of properties for new entity
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)createEntity:(NSDictionary *)newEntity;

/*!
 @abstract Asynchronously adds an entity to the specified collection
 @param newEntity Dictionary of properties for new entity
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)createEntity:(NSDictionary *)newEntity
                    completionHandler:(ApigeeDataClientCompletionHandler) completionHandler;

/*!
 @abstract Get a single entity by UUID
 @param type The collection (type) of the entity to retrieve
 @param uuid The UUID of the entity to be returned
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)getEntity:(NSString *)type
                               uuid:(NSString *)entityUuid;

/*!
 @abstract Get a list of entities by UUID
 @param type The collection (type) of the entities to retrieve
 @param uuids An array of uuids of the entities to be returned
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)getEntities:(NSString *)type
                               uuids:(NSArray *)uuidArray;

/*!
 @abstract Get a list of entities that meet the specified query
 @param type The collection (type) of the entities to retrieve
 @param query The query to restrict the returned entities
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getEntities:(NSString *)type
                               query:(ApigeeQuery *)query;

/*!
 @abstract Asynchronously get a list of entities that meet the specified query
 @param type The collection (type) of the entities to retrieve
 @param query The query to restrict the returned entities
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getEntities:(NSString *)type
                               query:(ApigeeQuery *)query
                   completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get a list of entities that meet the specified query parameters
 @param type The collection (type) of the entities to retrieve
 @param queryParams Dictionary of query parameters to restrict the returned entities
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getEntities:(NSString *)type
                         queryParams:(NSDictionary *)queryParams;


/*!
 @abstract Get a list of entities that meet the specified query parameters
 @param type The collection (type) of the entities to retrieve
 @param queryParams Dictionary of query parameters to restrict the returned entities
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getEntities:(NSString *)type
                         queryParams:(NSDictionary *)queryParams
                   completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;


/*!
 @abstract Get a list of entities that meet the specified query
 @param type The collection (type) of the entities to retrieve
 @param queryString The query string to restrict the returned entities
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)getEntities:(NSString *)type
                         queryString:(NSString *)queryString;

/*!
 @abstract Asynchronously get a list of entities that meet the specified query
 @param type The collection (type) of the entities to retrieve
 @param queryString The query string to restrict the returned entities
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)getEntities:(NSString *)type
                         queryString:(NSString *)queryString
                   completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// updates an entity (it knows the type from the entity data)
/*!
 @abstract Updates an entity
 @param entityID The identifier for the entity to update
 @param entity Dictionary of new properties for the entity
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)updateEntity:(NSString *)entityID
                               entity:(NSDictionary *)updatedEntity;

// updates an entity (it knows the type from the entity data)
/*!
 @abstract Updates an entity
 @param entityID The identifier for the entity to update
 @param entity Dictionary of new properties for the entity
 @param query Dictionary of query params to attach to the update request
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)updateEntity:(NSString *)entityID
                               entity:(NSDictionary *)updatedEntity
                                query:(ApigeeQuery *)query;

/*!
 @abstract Asynchronously updates an entity
 @param entityID The identifier for the entity to update
 @param updatedEntity Dictionary of new properties for the entity
 @param query Dictionary of query params to attach to the update request
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)updateEntity:(NSString *)entityID
                               entity:(NSDictionary *)updatedEntity
                                query:(ApigeeQuery *)query
                    completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Asynchronously updates an entity
 @param entityID The identifier for the entity to update
 @param updatedEntity Dictionary of new properties for the entity
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)updateEntity:(NSString *)entityID
                               entity:(NSDictionary *)updatedEntity
                    completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Removes an entity of the specified type
 @param type The collection from which the entity will be removed
 @param entityID The identifier of the entity to remove
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removeEntity:(NSString *)type
                             entityID:(NSString *)entityID;

/*!
 @abstract Asynchronously removes an entity of the specified type
 @param type The collection from which the entity will be removed
 @param entityID The identifier of the entity to remove
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removeEntity:(NSString *)type
                             entityID:(NSString *)entityID
                    completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

//******************************************************************************
/*!
 @methodgroup Entity Connection Methods
 */
/*!
 @abstract Directionally connect two entities
 @param connectorType The collection type for the "from" connecting entity
 @param connectorID The identifier of the "from" connecting entity
 @param connectionType The type of the connection (e.g., "like")
 @param connecteeID The identifier of the "to" connecting entity
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion Directionally connect two entities. For instance, user "Bob" might
    like Lyons Restaurant.
 @textblock
    connectorType would be "users" (because Bob is a user)
    connectorID would be Bob's userID
    connectionType would be "like"
    connecteeID would be the UUID of Lyons Restaurant
 @/textblock
 */
-(ApigeeClientResponse *)connectEntities:(NSString *)connectorType
                             connectorID:(NSString *)connectorID
                                    type:(NSString *)connectionType
                             connecteeID:(NSString *)connecteeID;

/*!
 @abstract Directionally connect two entities asynchronously
 @param connectorType The collection type for the "from" connecting entity
 @param connectorID The identifier of the "from" connecting entity
 @param connectionType The type of the connection (e.g., "like")
 @param connecteeID The identifier of the "to" connecting entity
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion Directionally connect two entities. For instance, user "Bob" might
    like Lyons Restaurant.
 @textblock
    connectorType would be "users" (because Bob is a user)
    connectorID would be Bob's userID
    connectionType would be "like"
    connecteeID would be the UUID of Lyons Restaurant
 @/textblock
 */
-(ApigeeClientResponse *)connectEntities:(NSString *)connectorType
                             connectorID:(NSString *)connectorID
                                    type:(NSString *)connectionType
                             connecteeID:(NSString *)connecteeID
                       completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Directionally connect two entities
 @param connectorType The collection type for the "from" connecting entity
 @param connectorID The identifier of the "from" connecting entity
 @param connectionType The type of the connection (e.g., "like")
 @param connecteeType The collection type for the "to" connecting entity
 @param connecteeID The identifier of the "to" connecting entity
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion Directionally connect two entities. For instance, user "Bob" might
    follow user "Mary".
 @textblock
    connectorType would be "users" (because Bob is a user)
    connectorID would be Bob's userID
    connectionType would be "like"
    connecteeType would  be "users" (because Mary is a user)
    connecteeID would be Mary's userID
 @/textblock
 */
-(ApigeeClientResponse *)connectEntities:(NSString *)connectorType
                             connectorID:(NSString *)connectorID
                          connectionType:(NSString *)connectionType
                           connecteeType:(NSString *)connecteeType
                             connecteeID:(NSString *)connecteeID;

/*!
 @abstract Directionally connect two entities asynchronously
 @param connectorType The collection type for the "from" connecting entity
 @param connectorID The identifier of the "from" connecting entity
 @param connectionType The type of the connection (e.g., "like")
 @param connecteeType The collection type for the "to" connecting entity
 @param connecteeID The identifier of the "to" connecting entity
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion Directionally connect two entities. For instance, user "Bob" might
    follow user "Mary".
 @textblock
    connectorType would be "users" (because Bob is a user)
    connectorID would be Bob's userID
    connectionType would be "like"
    connecteeType would  be "users" (because Mary is a user)
    connecteeID would be Mary's userID
 @/textblock
 */
-(ApigeeClientResponse *)connectEntities:(NSString *)connectorType
                             connectorID:(NSString *)connectorID
                          connectionType:(NSString *)connectionType
                           connecteeType:(NSString *)connecteeType
                             connecteeID:(NSString *)connecteeID
                       completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Disconnect two entities
 @param connectorType The collection type for the "from" connecting entity
 @param connectorID The identifier of the "from" connecting entity
 @param connectionType The type of the connection (e.g., "like")
 @param connecteeType The collection type for the "to" connecting entity
 @param connecteeID The identifier of the "to" connecting entity
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion It uses the same parameters and calling rules as connectEntities
 */
-(ApigeeClientResponse *)disconnectEntitiesByName:(NSString *)connectorType
                                connectorID:(NSString *)connectorID
                                       type:(NSString *)connectionType
                                connecteeType:(NSString *)connecteeType
                                connecteeID:(NSString *)connecteeID;

/*!
 @abstract Asynchronously disconnect two entities
 @param connectorType The collection type for the "from" connecting entity
 @param connectorID The identifier of the "from" connecting entity
 @param connectionType The type of the connection (e.g., "like")
 @param connecteeType The collection type for the "to" connecting entity
 @param connecteeID The identifier of the "to" connecting entity
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion It uses the same parameters and calling rules as connectEntities
 */
-(ApigeeClientResponse *)disconnectEntitiesByName:(NSString *)connectorType
                                connectorID:(NSString *)connectorID
                                       type:(NSString *)connectionType
                                connecteeType:(NSString *)connecteeType
                                connecteeID:(NSString *)connecteeID
                          completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Disconnect two entities
 @param connectorType The collection type for the "from" connecting entity
 @param connectorID The identifier of the "from" connecting entity
 @param connectionType The type of the connection (e.g., "like")
 @param connecteeID The identifier of the "to" connecting entity
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion It uses the same parameters and calling rules as connectEntities
 */
-(ApigeeClientResponse *)disconnectEntities:(NSString *)connectorType
                                connectorID:(NSString *)connectorID
                                       type:(NSString *)connectionType
                                connecteeID:(NSString *)connecteeID;

/*!
 @abstract Asynchronously disconnect two entities
 @param connectorType The collection type for the "from" connecting entity
 @param connectorID The identifier of the "from" connecting entity
 @param connectionType The type of the connection (e.g., "like")
 @param connecteeID The identifier of the "to" connecting entity
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion It uses the same parameters and calling rules as connectEntities
 */
-(ApigeeClientResponse *)disconnectEntities:(NSString *)connectorType
                                connectorID:(NSString *)connectorID
                                       type:(NSString *)connectionType
                                connecteeID:(NSString *)connecteeID
                          completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get entity connections
 @param connectorType
 @param connectorID
 @param connectionType
 @param query
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getEntityConnections:(NSString *)connectorType
                                  connectorID:(NSString *)connectorID
                               connectionType:(NSString *)connectionType
                                        query:(ApigeeQuery *)query;

/*!
 @abstract Asynchronously get entity connections
 @param connectorType
 @param connectorID
 @param connectionType
 @param query
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getEntityConnections:(NSString *)connectorType
                                  connectorID:(NSString *)connectorID
                               connectionType:(NSString *)connectionType
                                        query:(ApigeeQuery *)query
                            completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get entities connected to the specified entity with the specified connection
 @param connectorType
 @param connectorID
 @param connectionType
 @param query
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getConnectedEntities:(NSString *)connectorType
                                  connectorID:(NSString *)connectorID
                               connectionType:(NSString *)connectionType
                                        query:(ApigeeQuery *)query;

/*!
 @abstract Asynchronously get entities connected to the specified entity with the specified connection
 @param connectorType
 @param connectorID
 @param connectionType
 @param query
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getConnectedEntities:(NSString *)connectorType
                                  connectorID:(NSString *)connectorID
                               connectionType:(NSString *)connectionType
                                        query:(ApigeeQuery *)query
                            completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/********************* MESSAGE MANAGEMENT *********************/
/*!
 @methodgroup Message Management Methods
 */
/*!
 @abstract Post a message to a given queue
 @param queuePath The path of the queue
 @param message Dictionary of message properties
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)postMessage:(NSString *)queuePath
                             message:(NSDictionary *)message;

/*!
 @abstract Asynchronously post a message to a given queue
 @param queuePath The path of the queue
 @param message Dictionary of message properties
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)postMessage:(NSString *)queuePath
                             message:(NSDictionary *)message
                   completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get all messages from the queue path
 @param queuePath The path of the queue
 @param query The query to restrict which messages are returned
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getMessages:(NSString *)queuePath
                               query:(ApigeeQuery *)query;

/*!
 @abstract Asynchronously get all messages from the queue path
 @param queuePath The path of the queue
 @param query The query to restrict which messages are returned
 @param completionHandler The callback to call when the request completes
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 @see ApigeeQuery ApigeeQuery
 */
-(ApigeeClientResponse *)getMessages:(NSString *)queuePath
                               query:(ApigeeQuery *)query
                   completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Add a subscriber to a queue
 @param queuePath The path of the queue
 @param subscriberPath The path of the subscriber
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)addSubscriber:(NSString *)queuePath
                        subscriberPath:(NSString *)subscriberPath;

/*!
 @abstract Asynchronously add a subscriber to a queue
 @param queuePath The path of the queue
 @param subscriberPath The path of the subscriber
 @param completionHandler The callback to call when the request completes
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)addSubscriber:(NSString *)queuePath
                        subscriberPath:(NSString *)subscriberPath
                     completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Remove a subscriber from a queue
 @param queuePath The path of the queue
 @param subscriberPath The path of the subscriber
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removeSubscriber:(NSString *)queuePath
                           subscriberPath:(NSString *)subscriberPath;

/*!
 @abstract Asynchronously remove a subscriber from a queue
 @param queuePath The path of the queue
 @param subscriberPath The path of the subscriber
 @param completionHandler The callback to call when the request completes
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)removeSubscriber:(NSString *)queuePath
                           subscriberPath:(NSString *)subscriberPath
                        completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;


/********************* SERVER-SIDE STORAGE *********************/
/*!
 @methodgroup Server-Side Storage Methods
 */
/*!
 @abstract Put the device-specific data in to the remote storage
 @param data The data to store for the device
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion Each call to setRemoteStorage replaces whatever was there before.
 */
-(ApigeeClientResponse *)setRemoteStorage:(NSDictionary *)data;

/*!
 @abstract Asynchronously put the device-specific data in to the remote storage
 @param data The data to store for the device
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion Each call to setRemoteStorage replaces whatever was there before.
 */
-(ApigeeClientResponse *)setRemoteStorage:(NSDictionary *)data
                        completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Get the device-specific data from remote storage
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)getRemoteStorage;

/*!
 @abstract Asynchronously get the device-specific data from remote storage
 @param completionHandler The callback to call when request completes
 @return instance of ApigeeClientResponse
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)getRemoteStorage:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Returns a UUID for the device
 @return the globally unique identifier for the device
 @discussion This method will always return the same value for the same handset.
    NOTE - This value will change if the operating system is reinstalled.
 */
+(NSString *)getUniqueDeviceID;

/*********************** REMOTE PUSH NOTIFICATIONS ************************/
/*!
 @methodgroup Push Notification Methods
 */
// call from application:didRegisterForRemoteNotificationsWithDeviceToken: callback
// will automaticaly register the passed deviceToken with the Usergrid system
// using the getUniqueDeviceID method to associate this device on the server
/*!
 @abstract Registers the device token with the device for the given notifier
 @param newDeviceToken The device token received from APNS
 @param notifier The notifier to use for this device token registration
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion This method should be called from application:didRegisterForRemoteNotificationsWithDeviceToken:
 in your application delegate.
 */
- (ApigeeClientResponse *)setDevicePushToken:(NSData *)newDeviceToken
                                 forNotifier:(NSString *)notifier;

/*!
 @abstract Asynchronously registers the device token with the device for the given notifier
 @param newDeviceToken The device token received from APNS
 @param notifier The notifier to use for this device token registration
 @param completionHandler The callback to call when the request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
- (ApigeeClientResponse *)setDevicePushToken:(NSData *)newDeviceToken
                                 forNotifier:(NSString *)notifier
                           completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Push an "alert" type notification to the remote group, user, or
    device specified in the path argument
 @param message The alert message text
 @param sound The name of a sound file to be played on device when notification is received
 @param path The path to be evaluated to determine which devices will receive the notification
 @param notifier The notifier to use
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion The notifier may be a name or UUID of an APNS notifier that has
    been set up on the Usergrid server. If a sound file is specified, it must
    be present in the application bundle of the application that receives the
    notification.
 */
- (ApigeeClientResponse *)pushAlert:(NSString *)message
                          withSound:(NSString *)sound
                                 to:(NSString *)path
                      usingNotifier:(NSString *)notifier;

/*!
 @abstract Asynchronously push an "alert" type notification to the remote group, user, or
 device specified in the path argument
 @param message The alert message text
 @param sound The name of a sound file to be played on device when notification is received
 @param path The path to be evaluated to determine which devices will receive the notification
 @param notifier The notifier to use
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion The notifier may be a name or UUID of an APNS notifier that has
    been set up on the Usergrid server. If a sound file is specified, it must be
    present in the application bundle of the application that receives the
    notification.
 */
- (ApigeeClientResponse *)pushAlert:(NSString *)message
                          withSound:(NSString *)sound
                                 to:(NSString *)path
                      usingNotifier:(NSString *)notifier
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Sends a push notification using APNS
 @param apsPayload The APS payload object
 @param destination The destination for the push notification
 @param notifier The notifier to use
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse
 @see ApigeeAPSPayload
 @see ApigeeAPSDestination
 */
- (ApigeeClientResponse *)pushAlert:(ApigeeAPSPayload*)apsPayload
                        destination:(ApigeeAPSDestination*)destination
                      usingNotifier:(NSString*)notifier;

/*!
 @abstract Sends a push notification using APNS
 @param apsPayload The APS payload object
 @param destination The destination for the push notification
 @param notifier The notifier to use
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse
 @see ApigeeAPSPayload
 @see ApigeeAPSDestination
 */
- (ApigeeClientResponse *)pushAlert:(ApigeeAPSPayload*)apsPayload
                        destination:(ApigeeAPSDestination*)destination
                      usingNotifier:(NSString*)notifier
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Sends a push notification using APNS
 @param apsPayload The APS payload object
 @param customPayload A dictionary to use for custom payload (can be nil)
 @param destination The destination for the push notification
 @param notifier The notifier to use
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse
 @see ApigeeAPSPayload
 @see ApigeeAPSDestination
 @discussion If a custom payload is given, it will be set with the key 'custom'.
 */
- (ApigeeClientResponse *)pushAlert:(ApigeeAPSPayload*)apsPayload
                      customPayload:(NSDictionary*)customPayload
                        destination:(ApigeeAPSDestination*)destination
                      usingNotifier:(NSString*)notifier;

/*!
 @abstract Sends a push notification using APNS
 @param apsPayload The APS payload object
 @param customPayload A dictionary to use for custom payload (can be nil)
 @param destination The destination for the push notification
 @param notifier The notifier to use
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse
 @see ApigeeAPSPayload
 @see ApigeeAPSDestination
 @discussion If a custom payload is given, it will be set with the key 'custom'.
 */
- (ApigeeClientResponse *)pushAlert:(ApigeeAPSPayload*)apsPayload
                      customPayload:(NSDictionary*)customPayload
                        destination:(ApigeeAPSDestination*)destination
                      usingNotifier:(NSString*)notifier
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;


/*********************** ACCESSORS ************************/
/*!
 @methodgroup Accessor Methods
 */
/*!
 @abstract Retrieves OAuth token for the session
 @return the OAuth token for current session, or nil if not logged in
 @discussion ApigeeDataClient manages this internally, so you never really
    need it. But if you want it for other reasons, this accessor gives it to you.
 */
-(NSString *)getAccessToken;

/*!
 @abstract Returns information about the logged in user
 @return instance of ApigeeUser associated with the logged-in user
 @see ApigeeUser ApigeeUser
 */
-(ApigeeUser *)getLoggedInUser;

/*!
 @abstract Returns the delegate that is currently being used for asynch calls
 @discussion Returns nil if there is no delegate (synch mode)
 @return the delegate
 @see setDelegate:
 @see ApigeeClientDelegate ApigeeClientDelegate
 */
-(id<ApigeeClientDelegate>) getDelegate;

/*********************** OBLIQUE USAGE ************************/
/*!
 @methodgroup Oblique Usage Methods
 */
// url: The full URL that you are accessing. You are responsible for
//      assembling it, including the appID and all sub-sections down the line
//
// op: The HttpMethod being invoked. Examples: @"POST", @"PUT", etc. You may
//     send nil. If you do, the operation is GET. There is one specially supported
//     method called "POSTFORM". This will post with the data type set to 
//     application/x-www-form-urlencoded instead of the more likely needed
//     application/json. This is necessary if you are doing authentication
//     or if you are sending form data up. 
//
// opData: The data sent along with the operation. You may send nil. If the 
//         operation is GET, this value is ignored. Usually, this would be
//         expected to be in json format. With this oblique approach, it is
//         your responsibility to format the data correctly for whatever you're
//         doing.
//
// NOTE - This function will be synchronous or asynchronous the same as any
// other function in the API. It is based on the value sent to setDelegate.
/*!
 @abstract General purpose function for directly accessing the Usergrid service
 @param url The URL for the HTTP request
 @param op The requested HTTP operation ("GET","POST","POSTFORM","PUT", or "DELETE")
 @param opData Data associated with request
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion This is useful if the service has new features that the API has
    not yet supported, or if you are using an older version of the API and
    don't want to upgrade.
 */
-(ApigeeClientResponse *)apiRequest:(NSString *)url
                          operation:(NSString *)op
                               data:(NSString *)opData;

/*!
 @abstract Asynchronous general purpose function for directly accessing the Usergrid service
 @param url The URL for the HTTP request
 @param op The requested HTTP operation ("GET","POST","POSTFORM","PUT", or "DELETE")
 @param opData Data associated with request
 @param completionHandler The callback to call when request completes
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)apiRequest:(NSString *)url
                          operation:(NSString *)op
                               data:(NSString *)opData
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*********************** DEBUGGING ASSISTANCE ************************/
/*!
 @methodgroup Debugging Methods
 */
/*!
 @abstract Toggles debug logging on or off
 @param loggingState Boolean indicating whether debug logging should be performed
 @discussion When logging is on, all outgoing URLs are logged via NSLog, and all
    incoming data from the service is also logged. Additionally, any errors
    encountered internally are logged. This can be helpful to see the actual
    service communication in progress and help debug problems you may be having.
 */
-(void)setLogging:(BOOL)loggingState;


/*!
 @abstract Sets the logger to use for message logging
 @param aLogger The logging object that implements ApigeeLogging protocol
 @see ApigeeLogging
 */
+(void)setLogger:(id<ApigeeLogging>)aLogger;


/*!
 @abstract Writes out a log message as a debugging aid
 @param logMessage the logging message to log
 */
-(void)writeLog:(NSString*)logMessage;

//**********************  MISC  ******************************
/*!
 @internal
 @abstract
 @param uuid
 @return
 */
+(BOOL)isUuidValid:(NSString*)uuid;

/*!
 @internal
 @abstract
 @param type
 @return new ApigeeEntity instance
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeEntity*)createTypedEntity:(NSString*)type;


//**********************  COLLECTION  ************************
/*!
 @methodgroup Collection Retrieval Methods
 */
/*!
 @abstract Retrieves a collection by type name
 @param type The type whose collection is to be retrieved
 @return Instance of ApigeeCollection that corresponds to the collection
 @see ApigeeCollection ApigeeCollection
 */
-(ApigeeCollection*)getCollection:(NSString*)type;

/*!
 @abstract Retrieves a collection by type name
 @param type The type whose collection is to be retrieved
 @param completionHandler the handler to call when population of the collection has occurred
 @return Instance of ApigeeCollection that corresponds to the collection
 @see ApigeeCollection ApigeeCollection
 @discussion the returned collection instance is not ready to use (i.e., populated
 with data) until the completion handler is called
 */
-(ApigeeCollection*)getCollection:(NSString*)type
                completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Retrieves a collection by type name and query parameters
 @param type The type whose collection is to be retrieved
 @param qs The dictionary of query parameters to control the query
 @return Instance of ApigeeCollection that corresponds to the collection
 @see ApigeeCollection ApigeeCollection
 */
-(ApigeeCollection*)getCollection:(NSString*)type query:(NSDictionary*)qs;

/*!
 @abstract Retrieves a collection by type name and query parameters
 @param type The type whose collection is to be retrieved
 @param qs The dictionary of query parameters to control the query
 @param completionHandler the handler to call when population of the collection has occurred
 @return Instance of ApigeeCollection that corresponds to the collection
 @see ApigeeCollection ApigeeCollection
 @discussion the returned collection instance is not ready to use (i.e., populated
 with data) until the completion handler is called
 */
-(ApigeeCollection*)getCollection:(NSString*)type
                            query:(NSDictionary*)qs
                completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Retrieves a collection by type name and query
 @param type The type whose collection is to be retrieved
 @param query ApigeeQuery object to control the query
 @return Instance of ApigeeCollection that corresponds to the collection
 @see ApigeeCollection
 @see ApigeeQuery
 */
-(ApigeeCollection*)getCollection:(NSString*)type usingQuery:(ApigeeQuery*)query;

/*!
 @abstract Retrieves a collection by type name and query
 @param type The type whose collection is to be retrieved
 @param query ApigeeQuery object to control the query
 @param completionHandler the handler to call when population of the collection has occurred
 @return Instance of ApigeeCollection that corresponds to the collection
 @see ApigeeCollection
 @see ApigeeQuery
 @discussion the returned collection instance is not ready to use (i.e., populated
 with data) until the completion handler is called
 */
-(ApigeeCollection*)getCollection:(NSString*)type usingQuery:(ApigeeQuery*)query
                completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;



//**********************  HTTP HEADERS  **************************
/*!
 @methodgroup Custom HTTP Header Methods
 */
/*!
 @abstract Sets a custom HTTP header field and value for all subsequent
    network communication calls
 @param field The name of the field to set
 @param value The value for the field to be set
 */
-(void)addHTTPHeaderField:(NSString*)field withValue:(NSString*)value;

/*!
 @abstract Retrieves the value associated with a specified HTTP header field name
 @param field The field whose value is to be returned
 @return The value associated with the specified field name
 */
-(NSString*)getValueForHTTPHeaderField:(NSString*)field;

/*!
 @abstract Removes a custom HTTP header field that was previously set
 @param field Name of the custom HTTP field to remove
 */
-(void)removeHTTPHeaderField:(NSString*)field;

/*!
 @abstract Retrieves list of custom HTTP header fields that have been configured
 @return array of custom HTTP header fields that have been configured
 */
-(NSArray*)HTTPHeaderFields;

/*!
 @abstract Attaches an asset to the given entity asynchronously
 @param entity The entity in which to attach the asset to
 @param assetData The data for the asset
 @param assetFileName A filename to associate with the asset.
 @param assetContentType The content type of the asset you are uploading
 @param completionHandler The handler to call when the client has finished 
    its attempt to upload the asset and attach it to the entity.
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)attachAssetToEntity:(ApigeeEntity*)entity
                                   assetData:(NSData*)assetData
                               assetFileName:(NSString*)assetFileName
                            assetContentType:(NSString*)assetContentType
                           completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Attaches an asset to the given entity synchronously
 @param entity The entity in which to attach the asset to
 @param assetData The data for the asset
 @param assetFileName A filename to associate with the asset.
 @param assetContentType The content type of the asset you are uploading
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 */
-(ApigeeClientResponse *)attachAssetToEntity:(ApigeeEntity*)entity
                                   assetData:(NSData*)assetData
                               assetFileName:(NSString*)assetFileName
                            assetContentType:(NSString*)assetContentType;

/*!
 @abstract Retrives the asset attached to the given entity asynchronously
 @param entity The entity in which to attach the asset to
 @param acceptedContentType The content type of the attached asset.
 For example, text/plain, image/jpeg.
 @param completionHandler The handler to call when the client has finished
 its attempt to get the assets data.
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion The returned client response will contain the asset
 data in it's response property.
 */
-(ApigeeClientResponse*)getAssetDataForEntity:(ApigeeEntity *)entity
                          acceptedContentType:(NSString *)acceptedContentType
                            completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*!
 @abstract Retrives the asset attached to the given entity synchronously
 @param entity The entity in which to attach the asset to
 @param acceptedContentType The content type of the attached asset. 
    For example, text/plain, image/jpeg.
 @return ApigeeClientResponse instance
 @see ApigeeClientResponse ApigeeClientResponse
 @discussion The returned client response will contain the asset 
    data in it's response property.
 */
-(ApigeeClientResponse*)getAssetDataForEntity:(ApigeeEntity *)entity
                          acceptedContentType:(NSString *)acceptedContentType;


//**********************  OAUTH 2  **************************
/*!
 @abstract Retrives the access and refresh tokens using the OAuth2 grant_type of password
 @param accessTokenURL The access token URL
 @param userName The username to use for authorization
 @param password The password to use for authorization
 @param clientID The client_id to use for authorization
 @param completionHandler The completion handler that will be called once authorization has been completed.
 */
-(void)accessTokenWithURL:(NSString*)accessTokenURL
                 username:(NSString*)userName
                 password:(NSString*)password
                 clientID:(NSString*)clientID
        completionHandler:(ApigeeOAuth2CompletionHandler)completionHandler;

/*!
 @abstract Retrives the access and refresh tokens using the OAuth2 grant_type of client_credentials.
 @param accessTokenURL The access token URL
 @param clientID The client_id to use for authorization.
 @param clientSecret The client_secret to use for authorization.
 @param completionHandler The completion handler that will be called once authorization has been completed.
 @discussion The clientID and clientSecret will be sent using with basic auth in the Authorization header of the request.
 */
-(void)accessTokenWithURL:(NSString*)accessTokenURL
                 clientID:(NSString*)clientID
             clientSecret:(NSString*)clientSecret
        completionHandler:(ApigeeOAuth2CompletionHandler)completionHandler;

/*!
 @abstract Retrives the access and refresh tokens using the OAuth2 using the 3-legged approach
 @param serviceProvider The service providers name associated with the
 @param authorizeURL The authorization URL
 @param tokenURL The access token URL
 @param redirectURL The redirect URL
 @param clientID The client_id to use for authorization.
 @param clientSecret The client_secret to use for authorization.
 @param scope The scope of the authorization. Can be nil.
 @param keyChainItemName The name used to store the tokens within the systems keychain.
 @param navigationController The navigation contoller to use when showing the web view when authorizing.
 @param completionHandler The completion handler that will be called once authorization has been completed.
 */
-(void)authorizeOAuth2:(NSString*)serviceProvider
          authorizeURL:(NSString*)authorizeURL
              tokenURL:(NSString*)tokenURL
           redirectURL:(NSString*)redirectURL
              clientID:(NSString*)clientID
          clientSecret:(NSString*)clientSecret
                 scope:(NSString*)scope
      keyChainItemName:(NSString*)keyChainItemName
  navigationController:(UINavigationController*)navigationController
     completionHandler:(ApigeeOAuth2CompletionHandler)completionHandler;

/*!
 @abstract Stores the given OAuth2 access token and refresh token into the keychain under the given name.
 @param keychainItemName The keychain item name in which to store the tokens.
 @param accessToken The access token.
 @param refreshToken The refresh token.
 @param error If an error occurs while storing the tokens this will be populated with the error.
 */
-(void)storeOAuth2TokensInKeychain:(NSString*)keychainItemName
                       accessToken:(NSString*)accessToken
                      refreshToken:(NSString*)refreshToken
                             error:(NSError**)error;

/*!
 @abstract Retrives the OAuth2 access token and refresh token from the keychain with the given name.
 @param keychainItemName The keychain item name in which to store the tokens.
 @param completionHandler The completion handler that will be called once the tokens have been retrieved or if an error occurred.
 */
-(void)retrieveStoredOAuth2TokensFromKeychain:(NSString*)keychainItemName
                            completionHandler:(ApigeeOAuth2CompletionHandler)completion;

/*!
 @abstract Removes the OAuth2 access token and refresh token from the keychain with the given name.
 @param keychainItemName The keychain item name in which to store the tokens.
 */
-(void)removeStoredOAuth2TokensFromKeychain:(NSString*)keychainItemName;

//**********************  EVENTS AND COUNTERS  **************************
- (ApigeeClientResponse*)createEvent:(NSDictionary*)dictEvent;
- (ApigeeClientResponse*)createEvent:(NSDictionary*)dictEvent
                           timestamp:(NSDate*)timestamp;
- (ApigeeClientResponse*)createEvent:(NSDictionary*)dictEvent
                    counterIncrement:(ApigeeCounterIncrement*)counterIncrement;
- (ApigeeClientResponse*)createEvent:(NSDictionary*)dictEvent
                           timestamp:(NSDate*)timestamp
                    counterIncrement:(ApigeeCounterIncrement*)counterIncrement;
- (ApigeeClientResponse*)createEvent:(NSDictionary*)dictEvent
                           timestamp:(NSDate*)timestamp
                   counterIncrements:(NSArray*)counterIncrements;
- (ApigeeClientResponse*)getCounters:(NSArray*)counterArray;
- (ApigeeClientResponse*)getCountersByInterval:(NSArray*)counterArray
                                      startTime:(NSDate*)start_time
                                        endTime:(NSDate*)end_time
                                     resolution:(NSString*)interval;



/*********************** VERSION CHECKING ************************/
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@end
