#import <CoreLocation/CoreLocation.h>

#import "ApigeeDataClient.h"
#import "ApigeeHTTPManager.h"
#import "ApigeeActivity.h"
#import "ApigeeEntity.h"
#import "ApigeeDevice.h"
#import "ApigeeGroup.h"
#import "ApigeeMessage.h"
#import "ApigeeUser.h"
#import "ApigeeLogging.h"
#import "ApigeeCollection.h"
#import "ApigeeHTTPResult.h"
#import "UIDevice+Apigee.h"
#import "SSKeychain.h"
#import "ApigeeJsonUtils.h"
#import "ApigeeAPSPayload.h"
#import "ApigeeAPSDestination.h"
#import "ApigeeCounterIncrement.h"
#import "NSDate+Apigee.h"


static NSString* kDefaultBaseURL = @"https://api.usergrid.com";
static NSString* kLoggingTag = @"DATA_CLIENT";
static const int kInvalidTransactionID = -1;

static id<ApigeeLogging> logger = nil;

NSString *g_deviceUUID = nil;



@implementation ApigeeDataClient
{
    // the delegate for asynch callbacks
    id<ApigeeClientDelegate> m_delegate;
    
    // the mutex to protect the delegate variable
    NSRecursiveLock *m_delegateLock;
    
    // a growing array of ApigeeHTTPManager instances. See
    // "HTTPMANAGER POOLING" further down in this file.
    NSMutableArray *m_httpManagerPool;
    
    // the base URL for the service
    NSString *m_baseURL;
    
    // the appID for the specific app
    NSString *m_appID;
    
    // the orgID for the specific app
    NSString *m_orgID;
    
    // default url param to append to all calls
    NSString *m_urlTerms;
    
    // the cached auth token
    ApigeeUser *m_loggedInUser;
    
    // the auth code
    NSString *m_auth;
    
    // logging state
    BOOL m_bLogging;
    
    // custom HTTP headers
    NSMutableDictionary *m_dictCustomHTTPHeaders;
}


/************************** ACCESSORS *******************************/
/************************** ACCESSORS *******************************/
/************************** ACCESSORS *******************************/
+(NSString*)defaultBaseURL
{
    return kDefaultBaseURL;
}

+(NSString *) version
{
    return @"0.1.1";
}

-(NSString *)getAccessToken
{
    return m_auth;
}

-(ApigeeUser *)getLoggedInUser
{
    return m_loggedInUser;
}

-(id<ApigeeClientDelegate>) getDelegate
{
    return m_delegate;
}

/******************************* INIT *************************************/
/******************************* INIT *************************************/
/******************************* INIT *************************************/
-(id)init
{
    // you are not allowed to init without an organization id and application id
    // you can't init with [ApigeeClient new]. You must call
    // [[ApigeeClient alloc] initWithOrganizationId: <your Apigee org id> withApplicationId:<your Apigee app id>]
    assert(0); 
    return nil;
}

-(id) initWithOrganizationId: (NSString *)organizationID withApplicationID:(NSString *)applicationID
{
    return [self initWithOrganizationId:organizationID
                      withApplicationID:applicationID
                                baseURL:nil
                                urlTerms:nil];
}

-(id) initWithOrganizationId: (NSString *)organizationID withApplicationID:(NSString *)applicationID baseURL:(NSString *)baseURL urlTerms:(NSString *)urlTerms
{
    self = [super init];
    if ( self )
    {
        m_delegate = nil;
        m_httpManagerPool = [NSMutableArray new];
        m_delegateLock = [NSRecursiveLock new];
        m_appID = applicationID;
        m_orgID = organizationID;
        m_urlTerms = urlTerms;

        if ([baseURL length] > 0) {
            m_baseURL = [NSString stringWithString:baseURL];
        } else {
            m_baseURL = [ApigeeDataClient defaultBaseURL];
        }
        
        m_loggedInUser = nil;
        m_bLogging = NO;
        m_dictCustomHTTPHeaders = nil;
        
        // if the base URL has a trailing '/', leave it off
        if ([m_baseURL hasSuffix:@"/"]) {
            m_baseURL = [m_baseURL substringToIndex:[m_baseURL length]-1];
        }
    }
    
    return self;
}

-(BOOL) setDelegate:(id<ApigeeClientDelegate>)delegate
{
    // first off, clear any pending transactions
    for ( ApigeeHTTPManager *mgr in m_httpManagerPool )
    {
        // it's safe to call cancel at all times.
        [mgr cancel];
    }
    
    // nil is a valid answer. It means we're synchronous now.
    if ( delegate == nil )
    {
        [m_delegateLock lock];
        m_delegate = nil;
        [m_delegateLock unlock];
        return YES;
    }
    
    // if it's not nil, it has to have the delegation function
    if ( ![delegate respondsToSelector:@selector(apigeeClientResponse:)] )
    {
        return NO;
    }
    
    // if we're here, it means the delegate is valid
    [m_delegateLock lock];
    m_delegate = delegate;
    [m_delegateLock unlock];
    return YES;
}

/************************* HTTPMANAGER POOLING *******************************/
/************************* HTTPMANAGER POOLING *******************************/
/************************* HTTPMANAGER POOLING *******************************/

// any given instance of ApigeeHTTPManager can only manage one transaction at a time,
// but we want the client to be able to have as many going at once as he likes. 
// so we have a pool of ApigeeHTTPManagers as needed.
-(ApigeeHTTPManager *)getHTTPManager;
{
    // find the first unused HTTPManager
    for ( ApigeeHTTPManager *mgr in m_httpManagerPool )
    {
        if ( [mgr isAvailable] )
        {
            // tag this guy as available
            [mgr setAvailable:NO];
            
            // return him
            return mgr;
        }
    }
    
    // if we're here, we didn't find any available managers
    // so we'll need to make a new one
    ApigeeHTTPManager *newMgr = [ApigeeHTTPManager new];
    
    // mark it as in-use (we're about to return it)
    [newMgr setAvailable:NO];
    
    // tell it the auth to use
    [newMgr setAuth:m_auth];
    
    // give it custom HTTP headers, if we have any
    if ( m_dictCustomHTTPHeaders ) {
        NSArray *allHeaderFields = [m_dictCustomHTTPHeaders allKeys];
        for ( NSString *field in allHeaderFields ) {
            NSString *value = [m_dictCustomHTTPHeaders valueForKey:field];
            [newMgr addHTTPHeaderField:field withValue:value];
        }
    }
    
    // add it to the array
    [m_httpManagerPool addObject:newMgr];
    
    // return it
    return newMgr;
}

-(void)releaseHTTPManager:(ApigeeHTTPManager *)toRelease
{
    [toRelease setAvailable:YES];
}

-(void)setAuth:(NSString *)auth
{
    // note the auth for ourselves
    m_auth = auth;
    
    // update all our managers
    for ( ApigeeHTTPManager *mgr in m_httpManagerPool )
    {
        [mgr setAuth:m_auth];
    }
}

/************************* GENERAL WORKHORSES *******************************/
/************************* GENERAL WORKHORSES *******************************/
/************************* GENERAL WORKHORSES *******************************/
// url: the URL to hit
// op: a kApigeeHTTP constant. Example: kApigeeHTTPPost
// opData: The data to send along with the operation. Can be nil
-(ApigeeClientResponse *)httpTransaction:(NSString *)url op:(int)op opData:(NSString *)opData
{
    // get an http manager to do this transaction
    ApigeeHTTPManager *mgr = [self getHTTPManager];
    
    if ( m_delegate )
    {
        if ( m_bLogging )
        {
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
            NSLog(@"Asynch outgoing call: '%@'", url);
        }
        
        // asynch transaction
        int transactionID = [mgr asyncTransaction:url operation:op operationData:opData delegate:self];
        
        if ( m_bLogging )
        {
            NSLog(@"Transaction ID:%d", transactionID);
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n");
        }
        
        if ( transactionID == kInvalidTransactionID )
        {
            if ( m_bLogging )
            {
                NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
                NSLog(@"Response: ERROR: %@", [mgr getLastError]);
                NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n");
            }
            
            // there was an immediate failure in the transaction
            ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
            [response setTransactionID:kInvalidTransactionID];
            [response setTransactionState:kApigeeClientResponseFailure];
            [response setResponse:[mgr getLastError]];
            [response setRawResponse:nil];
            return response;
        }
        else 
        {
            // the transaction is in progress and pending
            ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
            [response setTransactionID:transactionID];
            [response setTransactionState:kApigeeClientResponsePending];
            [response setResponse:nil];
            [response setRawResponse:nil];
            return response;
        }
    }
    else 
    {
        if ( m_bLogging )
        {
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
            NSLog(@"Synch outgoing call: '%@'", url);
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n");
        }
        
        // synch transaction
        NSString *result = [mgr syncTransaction:url operation:op operationData:opData];
        
        if ( m_bLogging )
        {
            NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
            if ( result )
            {
                NSLog(@"Response:\n%@", result);
            }
            else
            {
                NSLog(@"Response: ERROR: %@", [mgr getLastError]);
            }
            NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n");
        }
        
        // since we're doing a synch transaction, we are now done with this manager.
        [self releaseHTTPManager:mgr];
        
        if ( result )
        {
            // got a valid result
            ApigeeClientResponse *response = [self createResponse:kInvalidTransactionID jsonStr:result];
            return response;
        }
        else 
        {
            // there was an error. Note the failure state, set the response to 
            // be the error string
            ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
            [response setTransactionID:kInvalidTransactionID];
            [response setTransactionState:kApigeeClientResponseFailure];
            [response setResponse:[mgr getLastError]];
            [response setRawResponse:nil];
            return response;
        }
    }
}

-(ApigeeClientResponse *)httpTransaction:(NSString *)url
                                      op:(int)op
                                  opData:(NSString *)opData
                       completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // get an http manager to do this transaction
    ApigeeHTTPManager *mgr = [self getHTTPManager];
    
    if ( m_bLogging )
    {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        NSLog(@"Asynch outgoing call: '%@'", url);
    }
        
    // asynch transaction
    int transactionID = [mgr asyncTransaction:url
                                    operation:op
                                operationData:opData
                            completionHandler:^(ApigeeHTTPResult *result, ApigeeHTTPManager *httpManager){
                                NSString *response = [result UTF8String];
                                if ( m_bLogging )
                                {
                                    NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
                                    NSLog(@"Response (Transaction ID %d):\n%@", [httpManager getTransactionID], response);
                                    NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n");
                                }
                                
                                // form up the response
                                ApigeeClientResponse *apigeeResponse =
                                    [self createResponse:[httpManager getTransactionID]
                                                 jsonStr:response];
                                
                                // execute the completion handler
                                completionHandler(apigeeResponse);
                                
                                // now that the callback is complete, it's safe to release this manager
                                [self releaseHTTPManager:httpManager];
                            }];
        
    if ( m_bLogging )
    {
        NSLog(@"Transaction ID:%d", transactionID);
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n");
    }
        
    if ( transactionID == kInvalidTransactionID )
    {
        if ( m_bLogging )
        {
            NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
            NSLog(@"Response: ERROR: %@", [mgr getLastError]);
            NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n");
        }
            
        // there was an immediate failure in the transaction
        ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [response setTransactionID:kInvalidTransactionID];
        [response setTransactionState:kApigeeClientResponseFailure];
        [response setResponse:[mgr getLastError]];
        [response setRawResponse:nil];
        return response;
    }
    else
    {
        // the transaction is in progress and pending
        ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [response setTransactionID:transactionID];
        [response setTransactionState:kApigeeClientResponsePending];
        [response setResponse:nil];
        [response setRawResponse:nil];
        return response;
    }
}

-(ApigeeClientResponse *)createResponse:(int)transactionID jsonStr:(NSString *)jsonStr
{
    ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
    
    // set the raw response and transaction id
    [response setRawResponse:jsonStr];
    [response setTransactionID:transactionID];
    
    // parse the json
    NSError *error;
    id result = [ApigeeJsonUtils decode:jsonStr error:&error];
    
    if ( result )
    {
        // first off, if the result is NOT an NSDictionary, something went wrong.
        // there should never be an array response
        if ( ![result isKindOfClass:[NSDictionary class]] )
        {
            [response setTransactionState:kApigeeClientResponseFailure];
            [response setResponse:@"Internal error: Response parsed to something other than NSDictionary"];
            return response;
        }
        
        // it successfully parsed. Though the result might still be an error.
        // it could be the server returning an error in perfectly formated json.
        NSString *err = [result valueForKey:@"error"];
        if ( err )
        {
            // there was an error. See if there's a more detailed description.
            // if there is, we'll use that. If not, we'll use the error value
            // itself.
            NSString *errDesc = [result valueForKey:@"error_description"];
            NSString *toReport = errDesc;
            if ( !toReport ) toReport = err;
            
            [response setTransactionState:kApigeeClientResponseFailure];
            [response setResponse:toReport];
            return response;
        }
        
        // if we're here we have a good auth. make note of it
        NSString *auth = [result valueForKey:@"access_token"];
        if ( auth )
        {
            [self setAuth: auth];
            
            // if there's an access token, there might be a user
            NSDictionary *dict = [result objectForKey:@"user"];
            if ( dict )
            {
                // get the fields for the user
                m_loggedInUser = [[ApigeeUser alloc] initWithDataClient:self];
                [m_loggedInUser setUsername:[dict valueForKey:@"username"]];
                [m_loggedInUser setName:[dict valueForKey:@"name"]];
                [m_loggedInUser setUuid:[dict valueForKey:@"uuid"]];
                [m_loggedInUser setEmail:[dict valueForKey:@"email"]];
                [m_loggedInUser setPicture:[dict valueForKey:@"picture"]];
                
                NSNumber *activated = [dict valueForKey:@"activated"];
                if( activated != nil ) {
                    [m_loggedInUser setActivated:[activated boolValue]];
                } else {
                    [m_loggedInUser setActivated:NO];
                }
                
                [m_loggedInUser addProperties:dict];
            }
        }
        
        [response setTransactionState:kApigeeClientResponseSuccess];
        [response setResponse:result];
        [response parse:jsonStr];
        return response;
    }
    else
    {
        // there was an error during json parsing. 
        [response setTransactionState:kApigeeClientResponseFailure];
        [response setResponse:[error localizedDescription]];
        return response;
    }
}

// basic URL assembly functions. For convenience
-(NSMutableString *)createURL:(NSString *)append1
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1];
    ret = [self appendDefaultUrlTerms:ret];
    return ret;
}

-(NSMutableString *)createURL:(NSString *)append1 append2:(NSString *)append2
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1, append2];
    ret = [self appendDefaultUrlTerms:ret];
    return ret;
}

-(NSMutableString *)createURL:(NSString *)append1 append2:(NSString *)append2 append3:(NSString *)append3
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1, append2, append3];
    ret = [self appendDefaultUrlTerms:ret];
    return ret;
}

-(NSMutableString *)createURL:(NSString *)append1 append2:(NSString *)append2 append3:(NSString *)append3 append4:(NSString *)append4
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1, append2, append3, append4];
    ret = [self appendDefaultUrlTerms:ret];
    return ret;
}

-(NSMutableString *)createURL:(NSString *)append1 append2:(NSString *)append2 append3:(NSString *)append3 append4:(NSString *)append4 append5:(NSString *)append5
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@/%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1, append2, append3, append4, append5];
    ret = [self appendDefaultUrlTerms:ret];
    return ret;
}

-(NSMutableString *)createURL:(NSString *)append1 append2:(NSString *)append2 append3:(NSString *)append3 append4:(NSString *)append4 append5:(NSString *)append5 append6:(NSString *)append6
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@/%@/%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1, append2, append3, append4, append5, append6];
    ret = [self appendDefaultUrlTerms:ret];
    return ret;
}

-(void)appendQueryToURL:(NSMutableString *)url query:(ApigeeQuery *)query
{
    if ( [url rangeOfString:@"?"].location != NSNotFound )
    {
        // we already have url params, so append
        [url appendFormat:@"&%@", [query getURLAppend]];
    } else {
        // no url params yet, so delimit the query in the url
        [url appendFormat:@"?%@", [query getURLAppend]];
    }
}

-(NSString *)createJSON:(NSDictionary *)data
{
    NSString *ret = [self createJSON:data error:nil];

    // the only way for ret to be nil here is for an internal
    // function to have a bApigee.
    assert(ret);
    return ret;
}

-(NSString *)createJSON:(NSDictionary *)data error:(NSString **)error
{
    NSError* errorObject = nil;
    NSString* jsonStr = [ApigeeJsonUtils encode:data error:&errorObject];
    if (jsonStr == nil) {
        if (*error) {
            *error = [errorObject localizedDescription];
        }
    }
    
    return jsonStr;
}

-(NSMutableString *)appendDefaultUrlTerms:(NSMutableString*)url
{
    if([m_urlTerms length] > 0) {
        [url appendFormat:@"?%@", m_urlTerms];
    }
    return url;
}
/************************** ApigeeHTTPMANAGER DELEGATES *******************************/
/************************** ApigeeHTTPMANAGER DELEGATES *******************************/
/************************** ApigeeHTTPMANAGER DELEGATES *******************************/
-(void)httpManagerError:(ApigeeHTTPManager *)manager error:(NSString *)error
{
    // prep an error response
    ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
    [response setTransactionID:[manager getTransactionID]];
    [response setTransactionState:kApigeeClientResponseFailure];
    [response setResponse:error];
    [response setRawResponse:nil];

    if ( m_bLogging )
    {
        NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
        NSLog(@"Response: ERROR: %@", error);
        NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n");
    }
    
    // fire it off. Wrap in mutex locks to ensure we don't get 
    // race conditions that cause us to fire it off to Mr. Nil.
    [m_delegateLock lock];
    if ( m_delegate )
    {
        [m_delegate performSelector:@selector(apigeeClientResponse:) withObject:response];
    }
    [m_delegateLock unlock];
    
    // now that the callback is complete, it's safe to release this manager
    [self releaseHTTPManager:manager];
}

-(void)httpManagerResponse:(ApigeeHTTPManager *)manager response:(NSString *)response
{
    if ( m_bLogging )
    {
        NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
        NSLog(@"Response (Transaction ID %d):\n%@", [manager getTransactionID], response);
        NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n");
    }
    
    // form up the response
    ApigeeClientResponse *apigeeResponse = [self createResponse:[manager getTransactionID]
                                                        jsonStr:response];
    
    // fire it off
    [m_delegateLock lock];
    if ( m_delegate )
    {
        [m_delegate performSelector:@selector(apigeeClientResponse:)
                         withObject:apigeeResponse];
    }
    [m_delegateLock unlock];   
    
    // now that the callback is complete, it's safe to release this manager
    [self releaseHTTPManager:manager];
}


/*************************** LOGIN / LOGOUT ****************************/
/*************************** LOGIN / LOGOUT ****************************/
/*************************** LOGIN / LOGOUT ****************************/
-(ApigeeClientResponse *)logInUser: (NSString *)userName password:(NSString *)password
{
    return [self logIn:@"password" userKey:@"username" userValue:userName pwdKey:@"password" pwdValue:password];
}

-(ApigeeClientResponse *)logInUser: (NSString *)userName password:(NSString *)password completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    return [self logIn:@"password"
               userKey:@"username"
             userValue:userName
                pwdKey:@"password"
              pwdValue:password
     completionHandler:completionHandler];
}

-(ApigeeClientResponse *)logInUserWithPin: (NSString *)userName pin:(NSString *)pin
{
    return [self logIn:@"pin" userKey:@"username" userValue:userName pwdKey:@"pin" pwdValue:pin];
}

-(ApigeeClientResponse *)logInUserWithPin: (NSString *)userName pin:(NSString *)pin completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    return [self logIn:@"pin"
               userKey:@"username"
             userValue:userName
                pwdKey:@"pin"
              pwdValue:pin
     completionHandler:completionHandler];
}

// log in user with Facebook token
//
//  //sample usage:
//  NSString * facebookToken = @"your-facebook-token";
//  ApigeeClientResponse *response = [apigeeDataClient logInUserWithFacebook:facebookToken];
//  user = [apigeeDataClient getLoggedInUser];
//  if (user.username){
//    return true;
//  } else {
//    return false;
//  }
//
-(ApigeeClientResponse *)logInUserWithFacebook: (NSString *)facebookToken
{
    NSMutableString *url = [self createURL:@"auth/facebook"];
    [url appendFormat:@"?fb_access_token=%@", facebookToken];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)logInUserWithFacebook: (NSString *)facebookToken
                             completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSMutableString *url = [self createURL:@"auth/facebook"];
    [url appendFormat:@"?fb_access_token=%@", facebookToken];
    return [self httpTransaction:url
                              op:kApigeeHTTPGet
                          opData:nil
               completionHandler:completionHandler];
}

-(ApigeeClientResponse *)logInAdmin: (NSString *)adminUserName secret:(NSString *)adminSecret
{
    return [self logIn:@"client_credentials" userKey:@"client_id" userValue:adminUserName pwdKey:@"client_secret" pwdValue:adminSecret];
}

-(ApigeeClientResponse *)logInAdmin: (NSString *)adminUserName secret:(NSString *)adminSecret completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    return [self logIn:@"client_credentials"
               userKey:@"client_id"
             userValue:adminUserName
                pwdKey:@"client_secret"
              pwdValue:adminSecret
     completionHandler:completionHandler];
}

-(void)logOut: (NSString*)username
{
    // clear out auth
    [self setAuth: nil];
    // create the URL
    NSString *url = [self createURL:@"users" append2:username append3:@"revoketoken?token=\"" append4:[self getAccessToken] append5:@"\""];
    [self httpTransaction:url op:kApigeeHTTPPut opData:nil];
}

-(void)logOut: (NSString*)username forToken:(NSString*)token
{
    if ([token isEqualToString: [self getAccessToken]]) {
        [self setAuth: nil];
    }
    NSString *url = [self createURL:@"users" append2:username append3:@"revoketoken?token=\"" append4:token append5:@"\""];
    [self httpTransaction:url op:kApigeeHTTPPut opData:nil];
}

-(void)logOutAllTokens: (NSString*)username
{
    [self setAuth: nil];
    NSString *url = [self createURL:@"users" append2:username append3:@"revoketokens"];
    [self httpTransaction:url op:kApigeeHTTPPut opData:nil];
}

// general workhorse for auth logins
-(ApigeeClientResponse *)logIn:(NSString *)grantType userKey:(NSString *)userKey userValue:(NSString *)userValue pwdKey:(NSString *)pwdKey pwdValue:(NSString *)pwdValue
{
    // create the URL
    NSString *url = [self createURL:@"token"];
    
    // because it's read as form data, we need to escape special characters.
    NSString *escapedUserValue = [ApigeeHTTPManager escapeSpecials:userValue];
    NSString *escapedPwdValue = [ApigeeHTTPManager escapeSpecials:pwdValue];
    
    // create the post data. For auth functions, we don't use json,
    // but instead use web form style data
    NSMutableString *postData = [NSMutableString new];
    [postData appendFormat:@"grant_type=%@&%@=%@&%@=%@", grantType, userKey, escapedUserValue, pwdKey, escapedPwdValue];
    
    // fire off the request
    return [self httpTransaction:url op:kApigeeHTTPPostAuth opData:postData];    
}

// general workhorse for auth logins
-(ApigeeClientResponse *)logIn:(NSString *)grantType userKey:(NSString *)userKey userValue:(NSString *)userValue pwdKey:(NSString *)pwdKey pwdValue:(NSString *)pwdValue completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // create the URL
    NSString *url = [self createURL:@"token"];
    
    // because it's read as form data, we need to escape special characters.
    NSString *escapedUserValue = [ApigeeHTTPManager escapeSpecials:userValue];
    NSString *escapedPwdValue = [ApigeeHTTPManager escapeSpecials:pwdValue];
    
    // create the post data. For auth functions, we don't use json,
    // but instead use web form style data
    NSMutableString *postData = [NSMutableString new];
    [postData appendFormat:@"grant_type=%@&%@=%@&%@=%@", grantType, userKey, escapedUserValue, pwdKey, escapedPwdValue];
    
    // fire off the request
    return [self httpTransaction:url op:kApigeeHTTPPostAuth opData:postData completionHandler:completionHandler];
}

/*************************** USER MANAGEMENT ***************************/
/*************************** USER MANAGEMENT ***************************/
/*************************** USER MANAGEMENT ***************************/
-(ApigeeClientResponse *)addUser:(NSString *)username email:(NSString *)email name:(NSString *)name password:(NSString *)password
{
    // make the URL we'll be posting to
    NSString *url = [self createURL:@"users"];
    
    // make the post data we'll be sending along with it.
    NSMutableDictionary *toPost = [NSMutableDictionary new];
    [toPost setObject:username forKey:@"username"];
    [toPost setObject:name forKey:@"name"];
    [toPost setObject:email forKey:@"email"];
    [toPost setObject:password forKey:@"password"];
    NSString *toPostStr = [self createJSON:toPost];
    
    // fire it off
    return [self httpTransaction:url op:kApigeeHTTPPost opData:toPostStr];
}

-(ApigeeClientResponse *)addUser:(NSString *)username email:(NSString *)email name:(NSString *)name password:(NSString *)password completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // make the URL we'll be posting to
    NSString *url = [self createURL:@"users"];
    
    // make the post data we'll be sending along with it.
    NSMutableDictionary *toPost = [NSMutableDictionary new];
    [toPost setObject:username forKey:@"username"];
    [toPost setObject:name forKey:@"name"];
    [toPost setObject:email forKey:@"email"];
    [toPost setObject:password forKey:@"password"];
    NSString *toPostStr = [self createJSON:toPost];
    
    // fire it off
    return [self httpTransaction:url op:kApigeeHTTPPost opData:toPostStr completionHandler:completionHandler];
}

// updates a user's password
-(ApigeeClientResponse *)updateUserPassword:(NSString *)usernameOrEmail oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword
{
    // make the URL we'll be posting to
    NSString *url = [self createURL:@"users" append2:usernameOrEmail append3:@"password"];
    
    // make the post data we'll be sending along with it.
    NSMutableDictionary *toPost = [NSMutableDictionary new];
    [toPost setObject:oldPassword forKey:@"oldpassword"];
    [toPost setObject:newPassword forKey:@"newpassword"];
    NSString *toPostStr = [self createJSON:toPost];
    
    // fire it off
    return [self httpTransaction:url op:kApigeeHTTPPost opData:toPostStr];
}

-(ApigeeClientResponse *)updateUserPassword:(NSString *)usernameOrEmail oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // make the URL we'll be posting to
    NSString *url = [self createURL:@"users" append2:usernameOrEmail append3:@"password"];
    
    // make the post data we'll be sending along with it.
    NSMutableDictionary *toPost = [NSMutableDictionary new];
    [toPost setObject:oldPassword forKey:@"oldpassword"];
    [toPost setObject:newPassword forKey:@"newpassword"];
    NSString *toPostStr = [self createJSON:toPost];
    
    // fire it off
    return [self httpTransaction:url op:kApigeeHTTPPost opData:toPostStr completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getGroupsForUser: (NSString *)userID;
{
    // make the URL, and fire off the get
    NSString *url = [self createURL:@"users" append2:userID append3:@"groups"];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)getGroupsForUser: (NSString *)userID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // make the URL, and fire off the get
    NSString *url = [self createURL:@"users" append2:userID append3:@"groups"];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getUsers: (ApigeeQuery *)query
{
    // create the URL
    NSMutableString *url = [self createURL:@"users"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)getUsers: (ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // create the URL
    NSMutableString *url = [self createURL:@"users"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse*)responseWithError:(NSError*)error
{
    ApigeeClientResponse *ret = [[ApigeeClientResponse alloc] initWithDataClient:self];
    [ret setTransactionState:kApigeeClientResponseFailure];
    [ret setTransactionID:kInvalidTransactionID];
    [ret setResponse:[error localizedDescription]];
    [ret setRawResponse:nil];
    return ret;
}

/************************** ACTIVITY MANAGEMENT **************************/
/************************** ACTIVITY MANAGEMENT **************************/
/************************** ACTIVITY MANAGEMENT **************************/
-(ApigeeClientResponse *)createActivity: (NSDictionary *)activity
{
    // make the URL
    NSString *url = [self createURL:@"activity"];
    
    // get the json to send.
    // we have to json-ify a dictionary that was sent
    // in by the client. So naturally, we can't just trust it 
    // to work. Therefore we can't use our internal convenience 
    // function for making the json. We go straight to SBJson, so
    // we can identify and report any errors.
    NSError *jsonError = nil;
    NSString *toPostStr = [ApigeeJsonUtils encode:activity error:&jsonError];

    if ( !toPostStr )
    {
        // error during json assembly
        return [self responseWithError:jsonError];
    }
    
    // fire it off
    return [self httpTransaction:url op:kApigeeHTTPPost opData:toPostStr];
}

-(ApigeeClientResponse *)createActivity: (NSDictionary *)activity completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // make the URL
    NSString *url = [self createURL:@"activity"];
    
    // get the json to send.
    // we have to json-ify a dictionary that was sent
    // in by the client. So naturally, we can't just trust it
    // to work. Therefore we can't use our internal convenience
    // function for making the json.
    
    NSError* jsonError = nil;
    NSString* toPostStr = [ApigeeJsonUtils encode:activity error:&jsonError];
    
    if ( !toPostStr )
    {
        // error during json assembly
        return [self responseWithError:jsonError];
    }
    
    // fire it off
    return [self httpTransaction:url op:kApigeeHTTPPost opData:toPostStr completionHandler:completionHandler];
}

// create an activity and post it to a user in a single step
-(ApigeeClientResponse *)postUserActivity: (NSString *)userID properties:(NSDictionary *)activityProperties
{
    ApigeeActivity *activity = [[ApigeeActivity alloc] init];
    [activity setProperties:activityProperties];
    return [self postUserActivity:userID activity:activity];
}

-(ApigeeClientResponse *)postUserActivity: (NSString *)userID activity:(ApigeeActivity *)activity
{
    NSDictionary *dictActivityProps = [activity toNSDictionary];

    // make sure it can parse to a json
    NSError* jsonError = nil;
    NSString* jsonStr = [ApigeeJsonUtils encode:dictActivityProps error:&jsonError];
    if ( !jsonStr )
    {
        ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [response setTransactionID:kInvalidTransactionID];
        [response setTransactionState:kApigeeClientResponseFailure];
        [response setError:[jsonError localizedDescription]];
        [response setRawResponse:nil];
        return response;
    }

    NSString *url = [self createURL:@"users" append2:userID append3:@"activities"];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:jsonStr];
}

-(ApigeeClientResponse *)postUserActivity: (NSString *)userID properties:(NSDictionary *)activityProperties completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    ApigeeActivity *activity = [[ApigeeActivity alloc] init];
    [activity setProperties:activityProperties];
    return [self postUserActivity:userID activity:activity completionHandler:completionHandler];
}

-(ApigeeClientResponse *)postUserActivity: (NSString *)userID activity:(ApigeeActivity *)activity completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSDictionary *dictActivityProps = [activity toNSDictionary];
    
    // make sure it can parse to a json
    NSError *jsonError = nil;
    NSString *jsonStr = [ApigeeJsonUtils encode:dictActivityProps error:&jsonError];
    if ( !jsonStr )
    {
        ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [response setTransactionID:kInvalidTransactionID];
        [response setTransactionState:kApigeeClientResponseFailure];
        [response setError:[jsonError localizedDescription]];
        [response setRawResponse:nil];
        return response;
    }
    
    NSString *url = [self createURL:@"users" append2:userID append3:@"activities"];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:jsonStr completionHandler:completionHandler];
}

-(ApigeeClientResponse *)postUserActivityByUUID: (NSString *)userID activity:(NSString *)activityUUID
{
    // make the URL and fire off the post. there is no data
    NSString *url = [self createURL:@"users" append2:userID append3:@"activities" append4:activityUUID];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];
}

-(ApigeeClientResponse *)postUserActivityByUUID: (NSString *)userID activity:(NSString *)activityUUID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // make the URL and fire off the post. there is no data
    NSString *url = [self createURL:@"users" append2:userID append3:@"activities" append4:activityUUID];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)postGroupActivity:(NSString *)groupID properties:(NSDictionary *)activityProperties
{
    ApigeeActivity *activity = [[ApigeeActivity alloc] init];
    [activity setProperties:activityProperties];
    return [self postGroupActivity:groupID activity:activity];
}

-(ApigeeClientResponse *)postGroupActivity:(NSString *)groupID activity:(ApigeeActivity *)activity
{
    NSDictionary *dictActivityProps = [activity toNSDictionary];
    
    // make sure it can parse to a json
    NSError *jsonError = nil;
    NSString *jsonStr = [ApigeeJsonUtils encode:dictActivityProps error:&jsonError];
    if ( !jsonStr )
    {
        ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [response setTransactionID:kInvalidTransactionID];
        [response setTransactionState:kApigeeClientResponseFailure];
        [response setError:[jsonError localizedDescription]];
        [response setRawResponse:nil];
        return response;
    }
    
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"activities"];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:jsonStr];
}

-(ApigeeClientResponse *)postGroupActivity: (NSString *)groupID properties:(NSDictionary *)activityProperties completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    ApigeeActivity *activity = [[ApigeeActivity alloc] init];
    [activity setProperties:activityProperties];
    return [self postGroupActivity:groupID activity:activity completionHandler:completionHandler];
}

-(ApigeeClientResponse *)postGroupActivity:(NSString *)groupID activity:(ApigeeActivity *)activity completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSDictionary *dictActivityProps = [activity toNSDictionary];
    
    // make sure it can parse to a json
    NSError *jsonError = nil;
    NSString *jsonStr = [ApigeeJsonUtils encode:dictActivityProps error:&jsonError];
    if ( !jsonStr )
    {
        ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [response setTransactionID:kInvalidTransactionID];
        [response setTransactionState:kApigeeClientResponseFailure];
        [response setError:[jsonError localizedDescription]];
        [response setRawResponse:nil];
        return response;
    }
    
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"activities"];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:jsonStr completionHandler:completionHandler];
}

-(ApigeeClientResponse *)postGroupActivityByUUID: (NSString *)groupID activity:(NSString *)activityUUID
{
    // make the URL and fire off the post. there is no data
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"activities" append4:activityUUID];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];    
}

-(ApigeeClientResponse *)postGroupActivityByUUID: (NSString *)groupID activity:(NSString *)activityUUID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // make the URL and fire off the post. there is no data
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"activities" append4:activityUUID];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getActivitiesForUser: (NSString *)userID query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:@"users" append2:userID append3:@"activities"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];    
}

-(ApigeeClientResponse *)getActivitiesForUser: (NSString *)userID query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSMutableString *url = [self createURL:@"users" append2:userID append3:@"activities"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getActivityFeedForUser: (NSString *)userID query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:@"users" append2:userID append3:@"feed"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];    
}

-(ApigeeClientResponse *)getActivityFeedForUser: (NSString *)userID query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSMutableString *url = [self createURL:@"users" append2:userID append3:@"feed"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getActivitiesForGroup: (NSString *)groupID query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:@"groups" append2:groupID append3:@"activities"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil]; 
}

-(ApigeeClientResponse *)getActivitiesForGroup: (NSString *)groupID query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSMutableString *url = [self createURL:@"groups" append2:groupID append3:@"activities"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getActivityFeedForGroup: (NSString *)groupID query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:@"groups" append2:groupID append3:@"feed"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil]; 
}

-(ApigeeClientResponse *)getActivityFeedForGroup: (NSString *)groupID query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSMutableString *url = [self createURL:@"groups" append2:groupID append3:@"feed"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)removeActivity:(NSString *)activityUUID
{
    NSString *url = [self createURL:@"activities" append2:activityUUID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
}

-(ApigeeClientResponse *)removeActivity:(NSString *)activityUUID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSString *url = [self createURL:@"activities" append2:activityUUID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil completionHandler:completionHandler];
}

/************************** GROUP MANAGEMENT **************************/
/************************** GROUP MANAGEMENT **************************/
/************************** GROUP MANAGEMENT **************************/
-(ApigeeClientResponse *)createGroup:(NSString *)groupPath groupTitle:(NSString *)groupTitle
{
    // make the URL
    NSString *url = [self createURL:@"groups"];
    
    // make the post data we'll be sending along with it.
    NSMutableDictionary *toPost = [NSMutableDictionary new];
    [toPost setObject:groupPath forKey:@"path"];
    if ( groupTitle )
    {
        [toPost setObject:groupTitle forKey:@"title"];
    }
    NSString *toPostStr = [self createJSON:toPost];
    
    // fire it off
    return [self httpTransaction:url op:kApigeeHTTPPost opData:toPostStr];
}

-(ApigeeClientResponse *)createGroup:(NSString *)groupPath groupTitle:(NSString *)groupTitle completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // make the URL
    NSString *url = [self createURL:@"groups"];
    
    // make the post data we'll be sending along with it.
    NSMutableDictionary *toPost = [NSMutableDictionary new];
    [toPost setObject:groupPath forKey:@"path"];
    if ( groupTitle )
    {
        [toPost setObject:groupTitle forKey:@"title"];
    }
    NSString *toPostStr = [self createJSON:toPost];
    
    // fire it off
    return [self httpTransaction:url op:kApigeeHTTPPost opData:toPostStr completionHandler:completionHandler];
}

-(ApigeeClientResponse *)addUserToGroup:(NSString *)userID group:(NSString *)groupID
{
    // make the URL
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"users" append4:userID];
    
    // fire it off. This is a data-less POST
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];
}

-(ApigeeClientResponse *)addUserToGroup:(NSString *)userID group:(NSString *)groupID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // make the URL
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"users" append4:userID];
    
    // fire it off. This is a data-less POST
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)removeUserFromGroup:(NSString *)userID group:(NSString *)groupID
{
    // this is identical to addUserToGroup, except we use the DELETE method instead of POST
    // make the URL
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"users" append4:userID];
    
    // fire it off. This is a data-less POST
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
}

-(ApigeeClientResponse *)removeUserFromGroup:(NSString *)userID group:(NSString *)groupID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // this is identical to addUserToGroup, except we use the DELETE method instead of POST
    // make the URL
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"users" append4:userID];
    
    // fire it off. This is a data-less POST
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getUsersForGroup:(NSString *)groupID query:(ApigeeQuery *)query
{
    // create the URL
    NSMutableString *url = [self createURL:@"groups" append2:groupID append3:@"users"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)getUsersForGroup:(NSString *)groupID query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // create the URL
    NSMutableString *url = [self createURL:@"groups" append2:groupID append3:@"users"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

/************************** ENTITY MANAGEMENT **************************/
/************************** ENTITY MANAGEMENT **************************/
/************************** ENTITY MANAGEMENT **************************/
// jsonify the entity. If there's an error, it creates a ApigeeClientResponse and 
// returns it. If there's no error, it returns nil, and the outJson field and
// the type field will be set correctly.
// yes, it's odd to have a function return nil on success, but it's internal.
-(ApigeeClientResponse *)validateEntity:(NSDictionary *)newEntity outJson:(NSString **)jsonStr outType:(NSString **)type
{
    // validation
    NSString *error = nil;
    
    // the entity must exist
    if ( !newEntity )
    {
        error =@"entity is nil";
    }
    
    // the entity must have a "type" field
    *type = [newEntity valueForKey:@"type"];
    if ( !*type )
    {
        error = @"entity is missing a type field";
    }
    
    // make sure it can parse to a json
    NSError *jsonError;
    *jsonStr = [ApigeeJsonUtils encode:newEntity error:&jsonError];
    if ( !*jsonStr )
    {
        error = [jsonError localizedDescription];
    }
    
    // if error got set to anything, it means we failed
    if ( error )
    {
        ApigeeClientResponse *ret = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [ret setTransactionState:kApigeeClientResponseFailure];
        [ret setTransactionID:kInvalidTransactionID];
        [ret setResponse:error];
        [ret setRawResponse:nil]; 
        return ret;
    }
    
    // if we're here, it's a good json and we're done
    return nil;
}

-(ApigeeClientResponse *)createEntity:(NSDictionary *)newEntity
{
    NSString *jsonStr;
    NSString *type;
    ApigeeClientResponse *errorRet = [self validateEntity:newEntity outJson:&jsonStr outType:&type];
    if ( errorRet ) return errorRet;
    
    // we have a valid entity, ready to post. Make the URL
    NSString *url = [self createURL:type];
    
    // post it
    return [self httpTransaction:url op:kApigeeHTTPPost opData:jsonStr];
}

-(ApigeeClientResponse *)createEntity: (NSDictionary *)newEntity
                    completionHandler: (ApigeeDataClientCompletionHandler) completionHandler
{
    NSString *jsonStr;
    NSString *type;
    ApigeeClientResponse *errorRet = [self validateEntity:newEntity outJson:&jsonStr outType:&type];
    if ( errorRet ) return errorRet;
    
    // we have a valid entity, ready to post. Make the URL
    NSString *url = [self createURL:type];
    
    // post it
    return [self httpTransaction:url
                              op:kApigeeHTTPPost
                          opData:jsonStr
               completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getEntity: (NSString *)type uuid:(NSString *)entityUuid
{
    NSMutableString *url = [self createURL:type];
    [url appendString:@"/"];
    [url appendString:entityUuid];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)getEntities: (NSString *)type uuids:(NSArray *)uuidArray
{
    NSMutableString *url = [self createURL:type];
    [url appendString:@"?ql=uuid="];
    NSString *queryString = [uuidArray componentsJoinedByString:@" OR uuid="];
    NSString* escapedQueryString = [ApigeeHTTPManager escapeSpecials:queryString];
    [url appendString:escapedQueryString];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)getEntities: (NSString *)type query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:type];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];    
}

-(ApigeeClientResponse *)getEntities: (NSString *)type query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSMutableString *url = [self createURL:type];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getEntities: (NSString *)type queryString:(NSString *)queryString
{
    NSMutableString *url = [self createURL:type];
    
    if ([queryString length] > 0) {
        [url appendString:@"?ql="];
        
        NSString* escapedQueryString = [ApigeeHTTPManager escapeSpecials:queryString];
        [url appendString:escapedQueryString];
    }
    
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)getEntities: (NSString *)type queryString:(NSString *)queryString completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSMutableString *url = [self createURL:type];
    
    if ([queryString length] > 0) {
        [url appendString:@"?ql="];
        
        NSString* escapedQueryString = [ApigeeHTTPManager escapeSpecials:queryString];
        [url appendString:escapedQueryString];
    }
    
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getEntities:(NSString *)type
                         queryParams:(NSDictionary *)queryParams
{
    ApigeeQuery* query = nil;
    
    if( [queryParams count] > 0 ) {
        query = [ApigeeQuery queryFromDictionary:queryParams];
    }
    
    return [self getEntities:type query:query];
}

-(ApigeeClientResponse *)getEntities:(NSString *)type
                         queryParams:(NSDictionary *)queryParams
                   completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    ApigeeQuery* query = nil;
    
    if( [queryParams count] > 0 ) {
        query = [ApigeeQuery queryFromDictionary:queryParams];
    }
    
    return [self getEntities:type query:query completionHandler:completionHandler];
}


-(ApigeeClientResponse *)updateEntity: (NSString *)entityID entity:(NSDictionary *)updatedEntity
{
    NSString *jsonStr;
    NSString *type;
    ApigeeClientResponse *errorRet = [self validateEntity:updatedEntity outJson:&jsonStr outType:&type];
    if ( errorRet ) return errorRet;
    
    // we have a valid entity, ready to post. Make the URL
    NSString *url = [self createURL:type append2:entityID];
    
    // post it
    return [self httpTransaction:url op:kApigeeHTTPPut opData:jsonStr];
}

-(ApigeeClientResponse *)updateEntity: (NSString *)entityID entity:(NSDictionary *)updatedEntity completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSString *jsonStr;
    NSString *type;
    ApigeeClientResponse *errorRet = [self validateEntity:updatedEntity outJson:&jsonStr outType:&type];
    if ( errorRet ) return errorRet;
    
    // we have a valid entity, ready to post. Make the URL
    NSString *url = [self createURL:type append2:entityID];
    
    // post it
    return [self httpTransaction:url op:kApigeeHTTPPut opData:jsonStr completionHandler:completionHandler];
}

-(ApigeeClientResponse *)updateEntity:(NSString *)entityID
                               entity:(NSDictionary *)updatedEntity
                                query:(ApigeeQuery *) query
{
    NSString *jsonStr;
    NSString *type;
    ApigeeClientResponse *errorRet = [self validateEntity:updatedEntity outJson:&jsonStr outType:&type];
    if ( errorRet ) return errorRet;
    
    // we have a valid entity, ready to post. Make the URL
    NSString *url = [self createURL:type append2:entityID];
    [self appendQueryToURL:url query:query];
    
    // post it
    return [self httpTransaction:url op:kApigeeHTTPPut opData:jsonStr];
}

-(ApigeeClientResponse *)updateEntity:(NSString *)entityID
                               entity:(NSDictionary *)updatedEntity
                                query:(ApigeeQuery *) query
                    completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSString *jsonStr;
    NSString *type;
    ApigeeClientResponse *errorRet = [self validateEntity:updatedEntity outJson:&jsonStr outType:&type];
    if ( errorRet ) return errorRet;
    
    // we have a valid entity, ready to post. Make the URL
    NSString *url = [self createURL:type append2:entityID];
    [self appendQueryToURL:url query:query];
    
    // post it
    return [self httpTransaction:url op:kApigeeHTTPPut opData:jsonStr completionHandler:completionHandler];
}

-(ApigeeClientResponse *)removeEntity: (NSString *)type entityID:(NSString *)entityID
{
    // Make the URL, then fire off the delete
    NSString *url = [self createURL:type append2:entityID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
}

-(ApigeeClientResponse *)removeEntity: (NSString *)type entityID:(NSString *)entityID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // Make the URL, then fire off the delete
    NSString *url = [self createURL:type append2:entityID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)connectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID connectionType:(NSString *)connectionType connecteeType:(NSString *)connecteeType connecteeID:(NSString *)connecteeID
{
    NSString *url = [self createURL:connectorType append2:connectorID append3:connectionType append4:connecteeType append5:connecteeID];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];
}

-(ApigeeClientResponse *)connectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeID:(NSString *)connecteeID
{
    NSString *url = [self createURL:connectorType append2:connectorID append3:connectionType append4:connecteeID];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];
}

-(ApigeeClientResponse *)connectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID connectionType:(NSString *)connectionType connecteeType:(NSString *)connecteeType connecteeID:(NSString *)connecteeID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSString *url = [self createURL:connectorType append2:connectorID append3:connectionType append4:connecteeType append5:connecteeID];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)connectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeID:(NSString *)connecteeID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSString *url = [self createURL:connectorType append2:connectorID append3:connectionType append4:connecteeID];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)disconnectEntitiesByName: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeType:(NSString *)connecteeType connecteeID:(NSString *)connecteeID
{
    NSString *url = [self createURL:connectorType append2:connectorID append3:connectionType append4:connecteeType append5:connecteeID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
}

-(ApigeeClientResponse *)disconnectEntitiesByName: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeType:(NSString *)connecteeType connecteeID:(NSString *)connecteeID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSString *url = [self createURL:connectorType append2:connectorID append3:connectionType append4:connecteeType append5:connecteeID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)disconnectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeID:(NSString *)connecteeID
{
    NSString *url = [self createURL:connectorType append2:connectorID append3:connectionType append4:connecteeID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
}

-(ApigeeClientResponse *)disconnectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeID:(NSString *)connecteeID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSString *url = [self createURL:connectorType append2:connectorID append3:connectionType append4:connecteeID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getEntityConnections: (NSString *)connectorType connectorID:(NSString *)connectorID connectionType:(NSString *)connectionType query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:connectorType append2:connectorID append3:connectionType];
    if (query) {
        [self appendQueryToURL:url query:query];
    }
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)getEntityConnections: (NSString *)connectorType connectorID:(NSString *)connectorID connectionType:(NSString *)connectionType query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSMutableString *url = [self createURL:connectorType append2:connectorID append3:connectionType];
    if (query) {
        [self appendQueryToURL:url query:query];
    }
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)buildErrorClientResponse:(NSString*)error
{
    ApigeeClientResponse *ret = [[ApigeeClientResponse alloc] initWithDataClient:self];
    [ret setTransactionID:kInvalidTransactionID];
    [ret setTransactionState:kApigeeClientResponseFailure];
    [ret setResponse:error];
    [ret setRawResponse:nil];
    return ret;
}

/************************** MESSAGE MANAGEMENT **************************/
/************************** MESSAGE MANAGEMENT **************************/
/************************** MESSAGE MANAGEMENT **************************/
-(ApigeeClientResponse *)postMessage: (NSString *)queuePath message:(NSDictionary *)message
{
    // because the NSDictionary is from the client, we can't trust it. We need
    // to go through full error checking
    NSString *error;
    NSString *jsonStr = [self createJSON:message error:&error];
    
    if ( !jsonStr )
    {
        // report the error
        return [self buildErrorClientResponse:error];
    }
    
    // make the path and fire it off
    NSString *url = [self createURL:@"queues" append2:queuePath];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:jsonStr];
}

-(ApigeeClientResponse *)postMessage:(NSString *)queuePath
                             message:(NSDictionary *)message
                   completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // because the NSDictionary is from the client, we can't trust it. We need
    // to go through full error checking
    NSString *error;
    NSString *jsonStr = [self createJSON:message error:&error];
    
    if ( !jsonStr )
    {
        // report the error
        return [self buildErrorClientResponse:error];
    }
    
    // make the path and fire it off
    NSString *url = [self createURL:@"queues" append2:queuePath];
    return [self httpTransaction:url
                              op:kApigeeHTTPPost
                          opData:jsonStr
               completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getMessages: (NSString *)queuePath query:(ApigeeQuery *)query;
{
    NSMutableString *url = [self createURL:@"queues" append2:queuePath];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)getMessages: (NSString *)queuePath query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSMutableString *url = [self createURL:@"queues" append2:queuePath];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)addSubscriber: (NSString *)queuePath subscriberPath:(NSString *)subscriberPath
{
    NSString *url = [self createURL:@"queues" append2:queuePath append3:@"subscribers" append4:subscriberPath];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];
}

-(ApigeeClientResponse *)addSubscriber: (NSString *)queuePath subscriberPath:(NSString *)subscriberPath completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSString *url = [self createURL:@"queues" append2:queuePath append3:@"subscribers" append4:subscriberPath];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil completionHandler:completionHandler];
}

-(ApigeeClientResponse *)removeSubscriber: (NSString *)queuePath subscriberPath:(NSString *)subscriberPath
{
    NSString *url = [self createURL:@"queues" append2:queuePath append3:@"subscribers" append4:subscriberPath];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
}

-(ApigeeClientResponse *)removeSubscriber: (NSString *)queuePath subscriberPath:(NSString *)subscriberPath completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSString *url = [self createURL:@"queues" append2:queuePath append3:@"subscribers" append4:subscriberPath];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil completionHandler:completionHandler];
}

/*************************** REMOTE PUSH NOTIFICATIONS ***************************/
/*************************** REMOTE PUSH NOTIFICATIONS ***************************/
/*************************** REMOTE PUSH NOTIFICATIONS ***************************/

- (void)populateDevicePushRegistration:(NSMutableDictionary*)entity withDeviceId:(NSString*)deviceId
{
    [entity setObject:@"device" forKey:@"type"];
    [entity setObject:deviceId forKey:@"uuid"];
    
    // grab device meta-data
    UIDevice *currentDevice = [UIDevice currentDevice];
    [entity setValue:[UIDevice platformStringDescriptive] forKey:@"deviceModel"];
    [entity setValue:[currentDevice systemName] forKey:@"devicePlatform"];
    [entity setValue:[currentDevice systemVersion] forKey:@"deviceOSVersion"];
}

- (ApigeeClientResponse *)setDevicePushToken:(NSData *)newDeviceToken forNotifier:(NSString *)notifier
{
    // Pull the push token string out of the device token data
    NSString *tokenString = [[[newDeviceToken description]
                              stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                             stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Register device and push token to App Services
    NSString *deviceId = [ApigeeDataClient getUniqueDeviceID];
    
    // create/update device - use deviceId for App Services entity UUID
    NSMutableDictionary *entity = [[NSMutableDictionary alloc] init];
    [self populateDevicePushRegistration:entity withDeviceId:deviceId];

    NSString *notifierKey = [notifier stringByAppendingString: @".notifier.id"];
    [entity setObject: tokenString forKey: notifierKey];
    
    return [self updateEntity:deviceId entity:entity];
}

- (ApigeeClientResponse *)setDevicePushToken:(NSData *)newDeviceToken forNotifier:(NSString *)notifier completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // Pull the push token string out of the device token data
    NSString *tokenString = [[[newDeviceToken description]
                              stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                             stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Register device and push token to App Services
    NSString *deviceId = [ApigeeDataClient getUniqueDeviceID];
    
    // create/update device - use deviceId for App Services entity UUID
    NSMutableDictionary *entity = [[NSMutableDictionary alloc] init];
    [self populateDevicePushRegistration:entity withDeviceId:deviceId];
    
    NSString *notifierKey = [notifier stringByAppendingString: @".notifier.id"];
    [entity setObject: tokenString forKey: notifierKey];
    
    return [self updateEntity:deviceId entity:entity completionHandler:completionHandler];
}

- (ApigeeClientResponse *)pushAlert:(NSString *)message
                          withSound:(NSString *)sound
                                 to:(NSString *)path
                      usingNotifier:(NSString *)notifier
{
    NSDictionary *apsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             message, @"alert",
                             sound, @"sound",
                             nil];
    
    NSDictionary *notifierDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  apsDict, @"aps",
                                  nil];
    
    NSDictionary *payloadsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  notifierDict, notifier,
                                  nil];
    
    NSString *notificationsPath = [path stringByAppendingString:@"/notifications"];
    
    NSMutableDictionary *entity = [[NSMutableDictionary alloc] init];
    [entity setObject: notificationsPath forKey:@"type"];
    [entity setObject: payloadsDict forKey:@"payloads"];
    
    return [self createEntity: entity];
}

- (ApigeeClientResponse *)pushAlert:(NSString *)message
                          withSound:(NSString *)sound
                                 to:(NSString *)path
                      usingNotifier:(NSString *)notifier
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSDictionary *apsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             message, @"alert",
                             sound, @"sound",
                             nil];
    
    NSDictionary *notifierDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  apsDict, @"aps",
                                  nil];
    
    NSDictionary *payloadsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  notifierDict, notifier,
                                  nil];
    
    NSString *notificationsPath = [path stringByAppendingString:@"/notifications"];
    
    NSMutableDictionary *entity = [[NSMutableDictionary alloc] init];
    [entity setObject: notificationsPath forKey:@"type"];
    [entity setObject: payloadsDict forKey:@"payloads"];
    
    return [self createEntity: entity completionHandler:completionHandler];
}

- (ApigeeClientResponse *)pushAlert:(ApigeeAPSPayload*)apsPayload
                        destination:(ApigeeAPSDestination*)destination
                      usingNotifier:(NSString*)notifier
{
    return [self pushAlert:apsPayload
             customPayload:nil
               destination:destination
             usingNotifier:notifier];
}

- (ApigeeClientResponse *)pushAlert:(ApigeeAPSPayload*)apsPayload
                        destination:(ApigeeAPSDestination*)destination
                      usingNotifier:(NSString*)notifier
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    return [self pushAlert:apsPayload
             customPayload:nil
               destination:destination
             usingNotifier:notifier
         completionHandler:completionHandler];
}

- (ApigeeClientResponse *)pushAlert:(ApigeeAPSPayload*)apsPayload
                      customPayload:(NSDictionary*)customPayload
                        destination:(ApigeeAPSDestination*)destination
                      usingNotifier:(NSString*)notifier
{
    NSDictionary *apsDict = [apsPayload toDictionary];
    
    NSDictionary *notifierDict;
    
    if ([customPayload count] > 0) {
        notifierDict = [NSDictionary dictionaryWithObjectsAndKeys:
                        apsDict, @"aps",
                        customPayload, @"custom",
                        nil];
    } else {
        notifierDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  apsDict, @"aps",
                                  nil];
    }
    
    NSDictionary *payloadsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  notifierDict, notifier,
                                  nil];
    
    NSString* notificationsPath = [NSString stringWithFormat:@"%@/notifications",
                                   [destination deliveryPath]];
    
    NSMutableDictionary *entity = [[NSMutableDictionary alloc] init];
    [entity setObject: notificationsPath forKey:@"type"];
    [entity setObject: payloadsDict forKey:@"payloads"];
    
    return [self createEntity: entity];
}

- (ApigeeClientResponse *)pushAlert:(ApigeeAPSPayload*)apsPayload
                      customPayload:(NSDictionary*)customPayload
                        destination:(ApigeeAPSDestination*)destination
                      usingNotifier:(NSString*)notifier
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSDictionary *apsDict = [apsPayload toDictionary];
    
    NSDictionary *notifierDict;
    
    if ([customPayload count] > 0) {
        notifierDict = [NSDictionary dictionaryWithObjectsAndKeys:
                        apsDict, @"aps",
                        customPayload, @"custom",
                        nil];
    } else {
        notifierDict = [NSDictionary dictionaryWithObjectsAndKeys:
                        apsDict, @"aps",
                        nil];
    }
    
    NSDictionary *payloadsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  notifierDict, notifier,
                                  nil];
    
    NSString* notificationsPath = [NSString stringWithFormat:@"%@/notifications",
                                   [destination deliveryPath]];
    
    NSMutableDictionary *entity = [[NSMutableDictionary alloc] init];
    [entity setObject: notificationsPath forKey:@"type"];
    [entity setObject: payloadsDict forKey:@"payloads"];
    
    return [self createEntity:entity
            completionHandler:completionHandler];
}


/*************************** SERVER-SIDE STORAGE ***************************/
/*************************** SERVER-SIDE STORAGE ***************************/
/*************************** SERVER-SIDE STORAGE ***************************/
+(NSString *)getUniqueDeviceID
{
    // cached?
    if (g_deviceUUID) return g_deviceUUID;
    
    // in our keychain?
    g_deviceUUID = [SSKeychain passwordForService:@"Usergrid" account:@"DeviceUUID"];
    if (g_deviceUUID) return g_deviceUUID;
    
    // in the (legacy) app defaults?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    g_deviceUUID = [defaults valueForKey:@"UGClientDeviceUUID"];
    
    // if none found in storage, generate one
    if (!g_deviceUUID) {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            // use identifierForVendor where possible
            g_deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
        else {
            // otherwise, create a UUID (legacy method)
            CFUUIDRef uuidRef = CFUUIDCreate(nil);
            CFStringRef uuidStringRef = CFUUIDCreateString(nil, uuidRef);
            CFRelease(uuidRef);
            g_deviceUUID = [NSString stringWithString:(__bridge NSString*) uuidStringRef];
            CFRelease(uuidStringRef);
        }
    }
    
    // store in keychain for future reference
    [SSKeychain setPassword:g_deviceUUID forService:@"Usergrid" account:@"DeviceUUID"];
    
    return g_deviceUUID;
}

-(ApigeeClientResponse *)setRemoteStorage: (NSDictionary *)data
{
    // prep and validate the sent-in dict
    NSString *error;
    NSString *jsonStr = [self createJSON:data error:&error];
    if ( !jsonStr )
    {
        // report the error
        ApigeeClientResponse *ret = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [ret setTransactionID:kInvalidTransactionID];
        [ret setTransactionState:kApigeeClientResponseFailure];
        [ret setResponse:error];
        [ret setRawResponse:nil];
        return ret;
    }
    
    NSString *handsetUUID = [ApigeeDataClient getUniqueDeviceID];
    NSString *url = [self createURL:@"devices" append2:handsetUUID];
    
    // this is a put. We replace whatever was there before
    return [self httpTransaction:url op:kApigeeHTTPPut opData:jsonStr];
}

-(ApigeeClientResponse *)setRemoteStorage: (NSDictionary *)data completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    // prep and validate the sent-in dict
    NSString *error;
    NSString *jsonStr = [self createJSON:data error:&error];
    if ( !jsonStr )
    {
        // report the error
        ApigeeClientResponse *ret = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [ret setTransactionID:kInvalidTransactionID];
        [ret setTransactionState:kApigeeClientResponseFailure];
        [ret setResponse:error];
        [ret setRawResponse:nil];
        return ret;
    }
    
    NSString *handsetUUID = [ApigeeDataClient getUniqueDeviceID];
    NSString *url = [self createURL:@"devices" append2:handsetUUID];
    
    // this is a put. We replace whatever was there before
    return [self httpTransaction:url op:kApigeeHTTPPut opData:jsonStr completionHandler:completionHandler];
}

-(ApigeeClientResponse *)getRemoteStorage
{
    NSString *handsetUUID = [ApigeeDataClient getUniqueDeviceID];
    NSString *url = [self createURL:@"devices" append2:handsetUUID];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)getRemoteStorage:(ApigeeDataClientCompletionHandler)completionHandler
{
    NSString *handsetUUID = [ApigeeDataClient getUniqueDeviceID];
    NSString *url = [self createURL:@"devices" append2:handsetUUID];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil completionHandler:completionHandler];
}

- (int)operationIdForOperation:(NSString*)op
{
    // work out the op to use
    int opID = kApigeeHTTPGet;
    
    if ( [op isEqualToString:@"GET"] ) opID = kApigeeHTTPGet;
    else if ( [op isEqualToString:@"POST"] ) opID = kApigeeHTTPPost;
    else if ( [op isEqualToString:@"POSTFORM"] ) opID = kApigeeHTTPPostAuth;
    else if ( [op isEqualToString:@"PUT"] ) opID = kApigeeHTTPPut;
    else if ( [op isEqualToString:@"DELETE"] ) opID = kApigeeHTTPDelete;

    return opID;
}

/***************************** OBLIQUE USAGE ******************************/
-(ApigeeClientResponse *)apiRequest: (NSString *)url operation:(NSString *)op data:(NSString *)opData
{
    // fire it off. The data, formatting, etc. is all the client's problem.
    // That's the way oblique functionality is. 
    return [self httpTransaction:url
                              op:[self operationIdForOperation:op]
                          opData:opData];
}

-(ApigeeClientResponse *)apiRequest: (NSString *)url
                          operation:(NSString *)op
                               data:(NSString *)opData
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    return [self httpTransaction:url
                              op:[self operationIdForOperation:op]
                          opData:opData
               completionHandler:completionHandler];
}

/**************************** LOGGING ************************************/
-(void)setLogging: (BOOL)loggingState
{
    m_bLogging = loggingState;
}

-(void)writeLog:(NSString*)logMessage
{
    if( (logger != nil) && m_bLogging ) {
        //TODO: do we support different log levels in this class?
        [logger debug:kLoggingTag message:logMessage];
    }
}

+(void)setLogger:(id<ApigeeLogging>)aLogger
{
    logger = aLogger;
}


//****************************  MISC  *************************************
+(BOOL)isUuidValid:(NSString*)uuid
{
    //TODO: how to properly validate uuid?
    return [[NSUUID alloc] initWithUUIDString:uuid];
}

- (ApigeeEntity*)createTypedEntity:(NSString*)type
{
    ApigeeEntity* entity = nil;
    
    if( [ApigeeActivity isSameType:type] ) {
        entity = [[ApigeeActivity alloc] initWithDataClient:self];
    } else if( [ApigeeDevice isSameType:type] ) {
        entity = [[ApigeeDevice alloc] initWithDataClient:self];
    } else if( [ApigeeGroup isSameType:type] ) {
        entity = [[ApigeeGroup alloc] initWithDataClient:self];
    } else if( [ApigeeMessage isSameType:type] ) {
        entity = [[ApigeeMessage alloc] initWithDataClient:self];
    } else if( [ApigeeUser isSameType:type] ) {
        entity = [[ApigeeUser alloc] initWithDataClient:self];
    } else {
        entity = [[ApigeeEntity alloc] initWithDataClient:self];
    }
    
    return entity;
}

//**********************  COLLECTION  ************************
-(ApigeeCollection*)getCollection:(NSString*)type
{
    return [self getCollection:type usingQuery:[[ApigeeQuery alloc] init]];
}

-(ApigeeCollection*)getCollection:(NSString*)type query:(NSDictionary*)qs
{
    return [[ApigeeCollection alloc] init:self type:type qs:qs];
}

-(ApigeeCollection*)getCollection:(NSString*)type usingQuery:(ApigeeQuery*)query
{
    return [[ApigeeCollection alloc] init:self type:type query:query];
}

-(ApigeeCollection*)getCollection:(NSString*)type
                completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    return [self getCollection:type
                         query:nil
             completionHandler:completionHandler];
}

-(ApigeeCollection*)getCollection:(NSString*)type
                            query:(NSDictionary*)qs
                completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    return [[ApigeeCollection alloc] init:self
                                     type:type
                                       qs:qs
                        completionHandler:completionHandler];
}

-(ApigeeCollection*)getCollection:(NSString*)type usingQuery:(ApigeeQuery*)query
                completionHandler:(ApigeeDataClientCompletionHandler)completionHandler
{
    return [[ApigeeCollection alloc] init:self
                                     type:type
                                    query:query
                        completionHandler:completionHandler];
}

//**********************  HTTP HEADER FIELDS  ***************************

-(void)addHTTPHeaderField:(NSString*)field withValue:(NSString*)value
{
    if ( ! m_dictCustomHTTPHeaders ) {
        m_dictCustomHTTPHeaders = [[NSMutableDictionary alloc] init];
    }
    
    [m_dictCustomHTTPHeaders setValue:value forKey:field];
    
    for ( ApigeeHTTPManager *mgr in m_httpManagerPool ) {
        [mgr addHTTPHeaderField:field withValue:value];
    }
}

-(NSString*)getValueForHTTPHeaderField:(NSString*)field
{
    if ( m_dictCustomHTTPHeaders ) {
        return [m_dictCustomHTTPHeaders valueForKey:field];
    }
    
    return nil;
}

-(void)removeHTTPHeaderField:(NSString*)field
{
    if ( m_dictCustomHTTPHeaders ) {
        [m_dictCustomHTTPHeaders removeObjectForKey:field];
        
        for ( ApigeeHTTPManager *mgr in m_httpManagerPool ) {
            [mgr removeHTTPHeaderField:field];
        }
    }
}

-(NSArray*)HTTPHeaderFields
{
    if ( m_dictCustomHTTPHeaders ) {
        return [m_dictCustomHTTPHeaders allKeys];
    }
    
    return nil;
}

//**********************  EVENTS AND COUNTERS  **************************

- (ApigeeClientResponse*)createEvent:(NSDictionary*)event
{
    // make the URL
    NSString *url = [self createURL:@"events"];
    
    // get the json to send.
    // we have to json-ify a dictionary that was sent
    // in by the client. So naturally, we can't just trust it
    // to work. Therefore we can't use our internal convenience
    // function for making the json. We go straight to SBJson, so
    // we can identify and report any errors.
    NSError *jsonError = nil;
    NSString *toPostStr = [ApigeeJsonUtils encode:event error:&jsonError];
    
    if ( !toPostStr )
    {
        // error during json assembly
        return [self responseWithError:jsonError];
    }
    
    // fire it off
    return [self httpTransaction:url op:kApigeeHTTPPost opData:toPostStr];
}

- (NSMutableDictionary*)mutableDictionaryForEvent:(NSDictionary*)dictEvent
{
    NSMutableDictionary* dictProps;
    
    if (dictEvent) {
        dictProps = [[NSMutableDictionary alloc] initWithDictionary:dictEvent];
    } else {
        dictProps = [[NSMutableDictionary alloc] init];
    }
    
    return dictProps;
}

- (void)populateTimestamp:(NSDate*)date event:(NSMutableDictionary*)dictEvent
{
    if (date) {
        const int64_t timestampMillis = [date dateAsMilliseconds];
        NSString* timestampValue = [NSDate stringFromMilliseconds:timestampMillis];
        [dictEvent setValue:timestampValue forKey:@"timestamp"];
    } else {
        // let the server assign the timestamp
        [dictEvent setValue:@"0" forKey:@"timestamp"];
    }
}

- (void)populateCounter:(ApigeeCounterIncrement*)counterIncrement
             dictionary:(NSMutableDictionary*)dict
{
    if (counterIncrement && ([counterIncrement.counterName length] > 0)) {
        
        NSMutableDictionary* dictCounters = nil;
        
        id existingCounters = [dict valueForKey:@"counters"];
        
        if (existingCounters != nil) {
            if ([existingCounters isKindOfClass:[NSMutableDictionary class]]) {
                dictCounters = (NSMutableDictionary*) existingCounters;
            } else if ([existingCounters isKindOfClass:[NSDictionary class]]) {
                NSDictionary* dict = (NSDictionary*) existingCounters;
                dictCounters = [[NSMutableDictionary alloc] initWithDictionary:dict];
            }
        }
        
        if (!dictCounters) {
            dictCounters = [[NSMutableDictionary alloc] init];
        }
        
        [dictCounters setValue:[NSNumber numberWithUnsignedInteger:counterIncrement.counterIncrementValue]
                        forKey:counterIncrement.counterName];
        [dict setValue:dictCounters forKey:@"counters"];
    }
}

- (ApigeeClientResponse*)createEvent:(NSDictionary*)dictEvent
                           timestamp:(NSDate*)timestamp
{
    NSMutableDictionary* dictProps = [self mutableDictionaryForEvent:dictEvent];
    [self populateTimestamp:timestamp event:dictProps];
    return [self createEvent:dictProps];
}

- (ApigeeClientResponse*)createEvent:(NSDictionary*)dictEvent
                    counterIncrement:(ApigeeCounterIncrement*)counterIncrement
{
    NSMutableDictionary* dictProps = [self mutableDictionaryForEvent:dictEvent];
    [self populateTimestamp:nil event:dictProps];
    [self populateCounter:counterIncrement dictionary:dictProps];
    return [self createEvent:dictProps];
}

- (ApigeeClientResponse*)createEvent:(NSDictionary*)dictEvent
                           timestamp:(NSDate*)timestamp
                    counterIncrement:(ApigeeCounterIncrement*)counterIncrement
{
    NSMutableDictionary* dictProps = [self mutableDictionaryForEvent:dictEvent];
    [self populateTimestamp:timestamp event:dictProps];
    [self populateCounter:counterIncrement dictionary:dictProps];
    return [self createEvent:dictProps];
}

- (ApigeeClientResponse*)createEvent:(NSDictionary*)dictEvent
                           timestamp:(NSDate*)timestamp
                   counterIncrements:(NSArray*)counterIncrements
{
    NSMutableDictionary* dictProps = [self mutableDictionaryForEvent:dictEvent];
    [self populateTimestamp:timestamp event:dictProps];
    
    for (ApigeeCounterIncrement* counterIncrement in counterIncrements) {
        [self populateCounter:counterIncrement dictionary:dictProps];
    }
    
    return [self createEvent:dictProps];
}

- (ApigeeClientResponse*) getCounters:(NSArray*)counterArray
{
    NSMutableString *url = [self createURL:@"counters"];
    [url appendString:@"?counter="];    
    [url appendString:[counterArray componentsJoinedByString:@"&counter="]];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

- (ApigeeClientResponse*) getCountersByInterval:(NSArray*)counterArray
                                      startTime:(NSDate*)start_time
                                       endTime:(NSDate*)end_time
                                     resolution:(NSString*)interval
{
    NSMutableString *url = [self createURL:@"counters"];
    [url appendString:@"?counter="];    
    [url appendString:[counterArray componentsJoinedByString:@"&counter="]];

    const int64_t startTimestampMillis = [start_time dateAsMilliseconds];
    NSString* startTimestampValue = [NSDate stringFromMilliseconds:startTimestampMillis];
    const int64_t endTimestampMillis = [end_time dateAsMilliseconds];
    NSString* endTimestampValue = [NSDate stringFromMilliseconds:endTimestampMillis];
    
    [url appendFormat:@"&start_time=%@&end_time=%@&resolution=%@",startTimestampValue,endTimestampValue,interval];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];    
}

@end


