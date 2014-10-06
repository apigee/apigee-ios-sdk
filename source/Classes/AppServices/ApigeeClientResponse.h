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
 @abstract Status of server request/transaction response states
 @constant kApigeeClientResponseSuccess The transaction succeeded
 @constant kApigeeClientResponseFailure The transaction failed
 @constant kApigeeClientResponsePending The transaction hasn't completed yet
 */
enum TransactionResponseState
{
    kApigeeClientResponseSuccess = 0,
    kApigeeClientResponseFailure = 1,
    kApigeeClientResponsePending = 2
};

@class ApigeeEntity;
@class ApigeeDataClient;
@class ApigeeUser;

/*!
 @class ApigeeClientResponse
 @abstract
 */
@interface ApigeeClientResponse : NSObject

/*!
 @property transactionID
 @abstract A unique ID for this transaction.
 @discussion If you have multiple transactions in progress, you can keep track
    of them with this value. Note: The transaction ID of a synchronous call
    response is always -1.
 */
@property int transactionID;

/*!
 @property transactionState
 @abstract Will be one of 3 possible values (kApigeeClientResponseSuccess,
    kApigeeClientResponseFailure, or kApigeeClientResponsePending)
 <pre>
 @textblock
 kApigeeClientResponseSuccess: The operation is complete and was successful. response will
                            be valid, as will rawResponse
 
 kApigeeClientResponseFailure: There was an error with the operation. No further
                           processing will be done. response will be an NSString with
                           a plain-text description of what went wrong. rawResponse
                           will be valid if the error occurred after receiving data from
                           the service. If it occurred before, rawResponse will be nil.
 
 kApigeeClientResponsePending: The call is being handled asynchronously and not yet complete.
                           response will be nil. rawResponse will also be nil
 @/textblock
 </pre>
 */
@property int transactionState;

/*!
 @property response
 @abstract This is the response. The type of this variable is dependant on the
    call that caused this response.
 */
@property (strong, nonatomic) id response;

/*!
 @property rawResponse
 @abstract This is the raw text that was returned by the server.
 */
@property (weak) NSString *rawResponse;
@property (weak) ApigeeDataClient *dataClient;

@property (copy, nonatomic) NSString *action;
@property (copy, nonatomic) NSString *organization;
@property (copy, nonatomic) NSString *application;
@property (copy, nonatomic) NSString *path;
@property (copy, nonatomic) NSString *uri;
@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *error;
@property (copy, nonatomic) NSString *errorDescription;
@property (copy, nonatomic) NSString *errorCode;
@property (copy, nonatomic) NSString *cursor;
@property (copy, nonatomic) NSString *next;
@property (strong, nonatomic) NSArray *entities;
@property (strong, nonatomic) NSDictionary *params;
@property (assign, nonatomic) long long timestamp;
@property (strong, nonatomic) ApigeeUser *user;


/*!
 @abstract Initializes new instance
 @param theDataClient The ApigeeDataClient instance
 */
- (id)initWithDataClient:(ApigeeDataClient*)theDataClient;

/*!
 @abstract Gets the number of retrieved entities
 @return number of retrieved entities as an integer
 */
- (NSUInteger)entityCount;

/*!
 @abstract Retrieves the first of the retrieved entities
 @return ApigeeEntity instance
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeEntity*)firstEntity;

/*!
 @abstract Retrieves the last of the retrieved entities
 @return ApigeeEntity instance
 @see ApigeeEntity ApigeeEntity
 */
- (ApigeeEntity*)lastEntity;

/*!
 @abstract Parses the response from the server and populates the instance
 @param serverResponse the response from the server
 */
- (void)parse:(NSString*)serverResponse;

/*!
 @abstract Determines if the server call completed successfully or not
 @return boolean indicating whether call was successful
 */
- (BOOL)completedSuccessfully;

@end
