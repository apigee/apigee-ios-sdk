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
 @abstract Type of HTTP operation
 @constant kApigeeHTTPGet GET
 @constant kApigeeHTTPPost POST
 @constant kApigeeHTTPPostAuth POST whose body is form encoded
 @constant kApigeeHTTPPut PUT
 @constant kApigeeHTTPDelete DELETE
 */
enum HTTP_Operation
{
    kApigeeHTTPGet = 0,
    kApigeeHTTPPost = 1,
    kApigeeHTTPPostAuth = 2,
    kApigeeHTTPPut = 3,
    kApigeeHTTPDelete = 4
};

@class ApigeeHTTPResult;
@class ApigeeHTTPManager;

typedef void (^ApigeeHTTPCompletionHandler)(ApigeeHTTPResult *result,ApigeeHTTPManager *httpManager);

/*!
 @class ApigeeHTTPManager
 @abstract
 */
@interface ApigeeHTTPManager : NSObject


/*!
 @abstract Performs synchronous HTTP call to server
 @param url the URL for the HTTP request
 @param op the HTTP operation (kApigeeHTTPGet, kApigeeHTTPPost,
    kApigeeHTTPPostAuth, kApigeeHTTPPut, or kApigeeHTTPDelete)
 @param opData data that should be sent to server as part of request
 @return the response received from the server, or nil in case of error
 @discussion blocks until a response is received, or until there's an error. in
    the event of a response, it's returned. If there's an error, the function
    returns nil and you can call getLastError to see what went wrong.
 */
-(NSString *)syncTransaction:(NSString *)url
                   operation:(int)op
               operationData:(NSString *)opData;

/*!
 @abstract Performs synchronous HTTP call to server
 @param urlRequest the URL request to perform
 @return the response received from the server, or nil in case of error
 @discussion blocks until a response is received, or until there's an error. in
 the event of a response, it's returned. If there's an error, the function
 returns nil and you can call getLastError to see what went wrong.
 */
-(NSString*)syncTransaction:(NSURLRequest*)urlRequest;

/*!
 @abstract Performs synchronous HTTP call to server returning NSData 
    instead of the converting the response to a string first.
 @param urlRequest the URL request to perform
 @return the response received from the server, or nil in case of error
 @discussion blocks until a response is received, or until there's an error. in
 the event of a response, it's returned. If there's an error, the function
 returns nil and you can call getLastError to see what went wrong.
 */
-(NSData*)syncTransactionRawData:(NSURLRequest*)urlRequest;

/*!
 @abstract Performs asynchronous HTTP call to server with delegate
 @param url the URL for the HTTP request
 @param op the HTTP operation (kApigeeHTTPGet, kApigeeHTTPPost,
    kApigeeHTTPPostAuth, kApigeeHTTPPut, or kApigeeHTTPDelete)
 @param opData data that should be sent to server as part of request
 @param delegate the delegate to call when the call completes
 @return the transactionID or -1 in case of error
 @discussion In the event of an error (-1), you can call getLastError to find out what
 went wrong. The delegate must implement these methods:
 @textblock
    -(void)httpManagerError:(ApigeeHTTPManager *)manager error:(NSString *)error
    -(void)httpManagerResponse:(ApigeeHTTPManager *)manager response:(NSString *)response
 @/textblock
 */
-(int)asyncTransaction:(NSString *)url
             operation:(int)op
         operationData:(NSString *)opData
              delegate:(id)delegate;

/*!
 @abstract Performs asynchronous HTTP call to server with delegate
 @param urlRequest the HTTP request to perform
 @param delegate the delegate to call when the call completes
 @return the transactionID or -1 in case of error
 @discussion In the event of an error (-1), you can call getLastError to find out what
 went wrong. The delegate must implement these methods:
 @textblock
 -(void)httpManagerError:(ApigeeHTTPManager *)manager error:(NSString *)error
 -(void)httpManagerResponse:(ApigeeHTTPManager *)manager response:(NSString *)response
 @/textblock
 */
-(int)asyncTransaction:(NSURLRequest*)urlRequest delegate:(id)delegate;

/*!
 @abstract Performs asynchronous HTTP call to server with completion block
 @param url the URL for the HTTP request
 @param op the HTTP operation (kApigeeHTTPGet, kApigeeHTTPPost,
    kApigeeHTTPPostAuth, kApigeeHTTPPut, or kApigeeHTTPDelete)
 @param opData data that should be sent to server as part of request
 @param completionHandler the block to call when the call completes
 @return the transactionID or -1 in case of error
 @discussion In the event of an error (-1), you can call getLastError to find
    out what went wrong.
 */
-(int)asyncTransaction:(NSString *)url
             operation:(int)op
         operationData:(NSString *)opData
     completionHandler:(ApigeeHTTPCompletionHandler) completionHandler;

/*!
 @abstract Performs asynchronous HTTP call to server with completion block
 @param urlRequest the HTTP request to perform
 @param completionHandler the block to call when the call completes
 @return the transactionID or -1 in case of error
 @discussion In the event of an error (-1), you can call getLastError to find
 out what went wrong.
 */
-(int)asyncTransaction:(NSURLRequest*)urlRequest completionHandler:(ApigeeHTTPCompletionHandler)theCompletionHandler;

/*!
 @abstract Used to create a NSURLRequest that will be set up to have all the correct Authorization and custom headers
    added along with the opStr added as the requests body.
 @param url the URL for the HTTP request
 @param op the HTTP operation (kApigeeHTTPGet, kApigeeHTTPPost,
 kApigeeHTTPPostAuth, kApigeeHTTPPut, or kApigeeHTTPDelete)
 @param opData data that should be sent to server as part of request
 @return the mutable URL request if creation was successful
 @discussion This method allows you to manipulate the URL requests further if needed and can be used with the methods in
    this class that take a full URL request.
 */
-(NSMutableURLRequest *)getRequest:(NSString *)url
                         operation:(int)op
                     operationData:(NSString *)opStr;

/*!
 @abstract get the current transactionID
 @return the current transactionID as int
 */
-(int)getTransactionID;

/*!
 @abstract sets the auth key
 @param auth the auth key
 */
-(void)setAuth: (NSString *)auth;

/*!
 @abstract cancel a pending transaction
 @discussion The delegate will not be called and the results will be ignored.
    Though the server side will still have happened.
 */
-(void)cancel;

/*!
 @abstract Determines if this instance is available
 @return boolean indicating whether the instance is currently available for use
 @discussion returns YES if this instance is available. NO if this instance is
    currently in use as part of an asynchronous transaction.
 */
-(BOOL)isAvailable;

/*!
 @abstract sets the availability flag of this instance
 @param available
 @discussion This is done by ApigeeClient
 */
-(void)setAvailable:(BOOL)available;

/*!
 @abstract a helpful utility function to make a string comform to URL rules
 @discussion It will escape all the special characters.
 @param raw the string that should be URL-encoded
 @return the URL-encoded string
 */
+(NSString *)escapeSpecials:(NSString *)raw;

/*!
 @abstract At all times, this will return the plain-text explanation of the last
    thing that went wrong.
 @discussion It is cleared to "No Error" at the beginning of each new transaction.
 */
-(NSString *)getLastError;

//**********************  HTTP HEADERS  **************************
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

@end
