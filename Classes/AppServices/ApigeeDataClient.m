#import "ApigeeDataClient.h"
#import "ApigeeHTTPManager.h"
#import "ApigeeSBJson.h"
#import "ApigeeSBJsonParser.h"
#import "ApigeeMultiStepAction.h"
#import "NSObject+ApigeeSBJson.h"
#import "ApigeeActivity.h"
#import "ApigeeEntity.h"
#import "ApigeeDevice.h"
#import "ApigeeGroup.h"
#import "ApigeeMessage.h"
#import "ApigeeUser.h"
#import "ApigeeLogger.h"
#import "ApigeeCollection.h"

static NSString* kDefaultBaseURL = @"http://api.usergrid.com";
static NSString* kLoggingTag = @"DATA_CLIENT";

static id<ApigeeLogger> logger = nil;

NSString *g_deviceUUID = nil;

@implementation ApigeeDataClient
{
    // the delegate for asynch callbacks
    id m_delegate;
    
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
    
    // the cached auth token
    ApigeeUser *m_loggedInUser;
    
    // the auth code
    NSString *m_auth;
    
    // the list of currently pending multi-step actions
    NSMutableArray *m_pendingMultiStepActions;
    
    // logging state
    BOOL m_bLogging;
}

/************************** ACCESSORS *******************************/
/************************** ACCESSORS *******************************/
/************************** ACCESSORS *******************************/
+(NSString*)defaultBaseURL
{
    return kDefaultBaseURL;
}

+(int) version
{
    return 1;
}

-(NSString *)getAccessToken
{
    return m_auth;
}

-(ApigeeUser *)getLoggedInUser
{
    return m_loggedInUser;
}

-(id) getDelegate
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
    self = [super init];
    if ( self )
    {
        m_delegate = nil;
        m_httpManagerPool = [NSMutableArray new];
        m_delegateLock = [NSRecursiveLock new];
        m_appID = applicationID;
        m_orgID = organizationID;
        m_baseURL = kDefaultBaseURL;
        m_pendingMultiStepActions = [NSMutableArray new];
        m_loggedInUser = nil;
        m_bLogging = NO;
    }
    return self;
}

//-(id) initWithApplicationID:(NSString *)applicationID baseURL:(NSString *)baseURL
-(id) initWithOrganizationId: (NSString *)organizationID withApplicationID:(NSString *)applicationID baseURL:(NSString *)baseURL
{
    self = [super init];
    if ( self )
    {
        m_delegate = nil;
        m_httpManagerPool = [NSMutableArray new];
        m_delegateLock = [NSRecursiveLock new];
        m_appID = applicationID;
        m_orgID = organizationID;
        m_baseURL = baseURL;
    }
    return self;
}

-(BOOL) setDelegate:(id)delegate
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
    if ( ![delegate respondsToSelector:@selector(ApigeeClientResponse:)] )
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
        
        if ( transactionID == -1 )
        {
            if ( m_bLogging )
            {
                NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
                NSLog(@"Response: ERROR: %@", [mgr getLastError]);
                NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n");
            }
            
            // there was an immediate failure in the transaction
            ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
            [response setTransactionID:-1];
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
            ApigeeClientResponse *response = [self createResponse:-1 jsonStr:result];
            return response;
        }
        else 
        {
            // there was an error. Note the failure state, set the response to 
            // be the error string
            ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
            [response setTransactionID:-1];
            [response setTransactionState:kApigeeClientResponseFailure];
            [response setResponse:[mgr getLastError]];
            [response setRawResponse:nil];
            return response;
        }
    }
}

-(ApigeeClientResponse *)createResponse:(int)transactionID jsonStr:(NSString *)jsonStr
{
    ApigeeClientResponse *response = [[ApigeeClientResponse alloc] initWithDataClient:self];
    
    // set the raw response and transaction id
    [response setRawResponse:jsonStr];
    [response setTransactionID:transactionID];
    
    // parse the json
    ApigeeSBJsonParser *parser = [ApigeeSBJsonParser new];
    NSError *error;
    id result = [parser objectWithString:jsonStr error:&error];
    
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
        
        // it successfully parsed. ThoApigeeh the result might still be an error.
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
                m_loggedInUser = [ApigeeUser new];
                [m_loggedInUser setUsername:[dict valueForKey:@"username"]];
                [m_loggedInUser setUuid:[dict valueForKey:@"uuid"]];
                [m_loggedInUser setEmail:[dict valueForKey:@"email"]];
                [m_loggedInUser setPicture:[dict valueForKey:@"picture"]];
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
    return ret;
}

-(NSMutableString *)createURL:(NSString *)append1 append2:(NSString *)append2
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1, append2];
    return ret;
}

-(NSMutableString *)createURL:(NSString *)append1 append2:(NSString *)append2 append3:(NSString *)append3
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1, append2, append3];
    return ret;
}

-(NSMutableString *)createURL:(NSString *)append1 append2:(NSString *)append2 append3:(NSString *)append3 append4:(NSString *)append4
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1, append2, append3, append4];
    return ret;
}

-(NSMutableString *)createURL:(NSString *)append1 append2:(NSString *)append2 append3:(NSString *)append3 append4:(NSString *)append4 append5:(NSString *)append5
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@/%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1, append2, append3, append4, append5];
    return ret;
}

-(NSMutableString *)createURL:(NSString *)append1 append2:(NSString *)append2 append3:(NSString *)append3 append4:(NSString *)append4 append5:(NSString *)append5 append6:(NSString *)append6
{
    NSMutableString *ret = [NSMutableString new];
    [ret appendFormat:@"%@/%@/%@/%@/%@/%@/%@/%@/%@", m_baseURL, m_orgID, m_appID, append1, append2, append3, append4, append5, append6];
    return ret;
}

-(void)appendQueryToURL:(NSMutableString *)url query:(ApigeeQuery *)query
{
    if ( query )
    {
        [url appendFormat:@"%@", [query getURLAppend]];
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
    ApigeeSBJsonWriter *writer = [ApigeeSBJsonWriter new];
    NSError *jsonError;
    NSString *jsonStr = [writer stringWithObject:data error:&jsonError];

    if ( jsonStr )
    {
        return jsonStr;
    }
    
    // if we're here, there was an assembly error
    if ( error )
    {
        *error = [jsonError localizedDescription];
    }
    return nil;
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
        [m_delegate performSelector:@selector(ApigeeClientResponse:) withObject:response];
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
    ApigeeClientResponse *ApigeeResponse = [self createResponse:[manager getTransactionID] jsonStr:response];
    
    // if this is part of a multi-step call, we press on.
    for ( ApigeeMultiStepAction *action in m_pendingMultiStepActions )
    {
        if ( [action transactionID] == [ApigeeResponse transactionID] )
        {
            // multi-step call. Fire off the action.
            ApigeeResponse = [self doMultiStepAction:action mostRecentResponse:ApigeeResponse];
            if ( ![action reportToClient] )
            {
                // the action is still pending. We do not report this
                // to the user. We're done with the httpmanager we were using,
                // thoApigeeh. 
                [self releaseHTTPManager:manager];
                return;
            }
            
            // when the action is complete, we want to immediately break
            // from this loop, then fall throApigeeh to the normal reporting
            // to the user. 
            break;
        }
    }
        
    // fire it off
    [m_delegateLock lock];
    if ( m_delegate )
    {
        [m_delegate performSelector:@selector(ApigeeClientResponse:) withObject:ApigeeResponse];
    }
    [m_delegateLock unlock];   
    
    // now that the callback is complete, it's safe to release this manager
    [self releaseHTTPManager:manager];
}

// multi-step follow-up function
-(ApigeeClientResponse *)multiStepAction: (ApigeeMultiStepAction *)action
{
    // different behavior if synch or asynch
    if ( m_delegate )
    {
        // asynch. Fire it off and we're done
        return [self doMultiStepAction:action mostRecentResponse:nil];
    }
    else 
    {
        // synchronous. keep calling until it finished or fails
        ApigeeClientResponse *response = nil;
        do 
        {
            response = [self doMultiStepAction:action mostRecentResponse:response];
            if ( [action reportToClient] )
            {
                // done
                return response;
            }
        } while ([response transactionState] == kApigeeClientResponseSuccess);
        
        // if we're here, there was an error
        return response;
    }
}

-(ApigeeClientResponse *)doMultiStepAction: (ApigeeMultiStepAction *)action mostRecentResponse:(ApigeeClientResponse *)mostRecentResponse
{
    // clear the pending array of this object
    [m_pendingMultiStepActions removeObject:action];

    // assume we aren't reporting to the client
    [action setReportToClient:NO];
    
    if ( mostRecentResponse )
    {
        // we don't care about pending responses
        if ( [mostRecentResponse transactionState] == kApigeeClientResponsePending )
        {
            // put ourselves back in the list
            [m_pendingMultiStepActions addObject:action];
            return mostRecentResponse;
        }
        
        // any failure is an immediate game ender
        if ( [mostRecentResponse transactionState] == kApigeeClientResponseFailure )
        {
            [mostRecentResponse setTransactionID:[action transactionID]];
            return mostRecentResponse;
        }
    }
    
    // if mostRecentRespons is nil, that means it's the first call to initiate 
    // the chain. So we continue on with processing.

    // so either we are reacting to a success or we are starting off the chain
    ApigeeClientResponse *result = nil; 
    if ( [action nextAction] == kMultiStepCreateActivity )
    {
        // create the activity
        result = [self createActivity:[action activity]];
        
        // advance ourselves to the next step
        [action setNextAction:kMultiStepPostActivity];
    }
    else if ( [action nextAction] == kMultiStepCreateGroupActivity )
    {
        // create the activity
        result = [self createActivity:[action activity]];
        
        // advance ourselves to the next step
        [action setNextAction:kMultiStepPostGroupActivity];
    }
    else if ( [action nextAction] == kMultiStepPostActivity )
    {
        // we just created an activity, now we need to associate it with a user.
        // first, we'll need the activity's uuid
        NSDictionary *dict = [mostRecentResponse response]; // dictionary for the response
        NSArray *entities = [dict objectForKey:@"entities"]; // array for the entities
        NSDictionary *activity = [entities objectAtIndex:0]; // dict for the activity
        NSString *activityUUID = [activity valueForKey:@"uuid"]; // and finally the uuid string
        
        // fire off the next step
        result = [self postUserActivityByUUID:[action userID] activity:activityUUID];
        
        // advance the action
        [action setNextAction:kMultiStepCleanup];
    }
    else if ( [action nextAction] == kMultiStepPostGroupActivity )
    {
        // we just created an activity, now we need to associate it with a user.
        // first, we'll need the activity's uuid
        NSDictionary *dict = [mostRecentResponse response]; // dictionary for the response
        NSArray *entities = [dict objectForKey:@"entities"]; // array for the entities
        NSDictionary *activity = [entities objectAtIndex:0]; // dict for the activity
        NSString *activityUUID = [activity valueForKey:@"uuid"]; // and finally the uuid string
        
        // fire off the next step
        result = [self postGroupActivityByUUID:[action groupID] activity:activityUUID];
        
        // advance the action
        [action setNextAction:kMultiStepCleanup];
    }
    else if ( [action nextAction] == kMultiStepCleanup )
    {
        // all we do in cleanup is update the transaction ID of the 
        // response that was sent in. We do this to ensure that the transaction
        // id is constant across the entire transaction
        result = mostRecentResponse;
        [result setTransactionID:[action outwardTransactionID]];
        [action setReportToClient:YES];
    }
    
    if ( !mostRecentResponse )
    {
        // if mostRecentResponse is nil, it means we're on the first step. That means
        // we need to adopt a unique outward transaction ID. We'll simply use
        // the ID given back by the first transaction in the chain. This also means
        // we can simply return the first transaction pending response without modification. 
        [action setOutwardTransactionID:[result transactionID]];
    }

    // wherever we landed, if it's a pending transaction, the action needs to
    // know that transaction ID. Also, we need to go in to the pending array
    if ( [result transactionState] == kApigeeClientResponsePending )
    {
        [action setTransactionID:[result transactionID]];
        [m_pendingMultiStepActions addObject:action];
    }
    
    // result is now properly set up and ready to be handed to the user. 
    return result;
}

/*************************** LOGIN / LOGOUT ****************************/
/*************************** LOGIN / LOGOUT ****************************/
/*************************** LOGIN / LOGOUT ****************************/
-(ApigeeClientResponse *)logInUser: (NSString *)userName password:(NSString *)password
{
    return [self logIn:@"password" userKey:@"username" userValue:userName pwdKey:@"password" pwdValue:password];
}

-(ApigeeClientResponse *)logInUserWithPin: (NSString *)userName pin:(NSString *)pin
{
    return [self logIn:@"pin" userKey:@"username" userValue:userName pwdKey:@"pin" pwdValue:pin];
}

-(ApigeeClientResponse *)logInAdmin: (NSString *)adminUserName secret:(NSString *)adminSecret
{
    return [self logIn:@"client_credentials" userKey:@"client_id" userValue:adminUserName pwdKey:@"client_secret" pwdValue:adminSecret];
}

-(void)logOut
{
    // clear out auth
    [self setAuth: nil];
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

-(ApigeeClientResponse *)getGroupsForUser: (NSString *)userID;
{
    // make the URL, and fire off the get
    NSString *url = [self createURL:@"users" append2:userID append3:@"groups"];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)getUsers: (ApigeeQuery *)query
{
    // create the URL
    NSMutableString *url = [self createURL:@"users"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
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
    ApigeeSBJsonWriter *writer = [ApigeeSBJsonWriter new];
    NSError *jsonError;
    NSString *toPostStr = [writer stringWithObject:activity error:&jsonError];

    if ( !toPostStr )
    {
        // error during json assembly
        ApigeeClientResponse *ret = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [ret setTransactionState:kApigeeClientResponseFailure];
        [ret setTransactionID:-1];
        [ret setResponse:[jsonError localizedDescription]];
        [ret setRawResponse:nil];
        return ret;
    }
    
    // fire it off
    return [self httpTransaction:url op:kApigeeHTTPPost opData:toPostStr];
}

// create an activity and post it to a user in a single step
-(ApigeeClientResponse *)postUserActivity: (NSString *)userID activity:(NSDictionary *)activity
{
    // prep a multi-step action
    ApigeeMultiStepAction *action = [ApigeeMultiStepAction new];
    
    // set it up to start the create activity / post to user chain
    [action setNextAction:kMultiStepCreateActivity];
    [action setUserID:userID];
    [action setActivity:activity];
    
    // fire it off
    return [self multiStepAction:action];
}

-(ApigeeClientResponse *)postUserActivityByUUID: (NSString *)userID activity:(NSString *)activityUUID
{
    // make the URL and fire off the post. there is no data
    NSString *url = [self createURL:@"users" append2:userID append3:@"activities" append4:activityUUID];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];
}

-(ApigeeClientResponse *)postGroupActivity:(NSString *)groupID activity:(NSDictionary *)activity
{
    // prep a multi-step action
    ApigeeMultiStepAction *action = [ApigeeMultiStepAction new];
    
    // set it up to start the create activity / post to user chain
    [action setNextAction:kMultiStepCreateGroupActivity];
    [action setGroupID:groupID];
    [action setActivity:activity];
    
    // fire it off
    return [self multiStepAction:action];    
}

-(ApigeeClientResponse *)postGroupActivityByUUID: (NSString *)groupID activity:(NSString *)activityUUID
{
    // make the URL and fire off the post. there is no data
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"activities" append4:activityUUID];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];    
}

-(ApigeeClientResponse *)getActivitiesForUser: (NSString *)userID query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:@"users" append2:userID append3:@"activities"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];    
}

-(ApigeeClientResponse *)getActivityFeedForUser: (NSString *)userID query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:@"users" append2:userID append3:@"feed"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];    
}

-(ApigeeClientResponse *)getActivitiesForGroup: (NSString *)groupID query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:@"groups" append2:groupID append3:@"activities"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil]; 
}

-(ApigeeClientResponse *)getActivityFeedForGroup: (NSString *)groupID query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:@"groups" append2:groupID append3:@"feed"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil]; 
}

-(ApigeeClientResponse *)removeActivity:(NSString *)activityUUID
{
    NSString *url = [self createURL:@"activities" append2:activityUUID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
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

-(ApigeeClientResponse *)addUserToGroup:(NSString *)userID group:(NSString *)groupID
{
    // make the URL
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"users" append4:userID];
    
    // fire it off. This is a data-less POST
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];
}

-(ApigeeClientResponse *)removeUserFromGroup:(NSString *)userID group:(NSString *)groupID
{
    // this is identical to addUserToGroup, except we use the DELETE method instead of POST
    // make the URL
    NSString *url = [self createURL:@"groups" append2:groupID append3:@"users" append4:userID];
    
    // fire it off. This is a data-less POST
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
}

-(ApigeeClientResponse *)getUsersForGroup:(NSString *)groupID query:(ApigeeQuery *)query
{
    // create the URL
    NSMutableString *url = [self createURL:@"groups" append2:groupID append3:@"users"];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
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
    ApigeeSBJsonWriter *writer = [ApigeeSBJsonWriter new];
    NSError *jsonError;
    *jsonStr = [writer stringWithObject:newEntity error:&jsonError];
    if ( !*jsonStr )
    {
        error = [jsonError localizedDescription];
    }
    
    // if error got set to anything, it means we failed
    if ( error )
    {
        ApigeeClientResponse *ret = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [ret setTransactionState:kApigeeClientResponseFailure];
        [ret setTransactionID:-1];
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

-(ApigeeClientResponse *)getEntities: (NSString *)type query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:type];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];    
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

-(ApigeeClientResponse *)removeEntity: (NSString *)type entityID:(NSString *)entityID
{
    // Make the URL, then fire off the delete
    NSString *url = [self createURL:type append2:entityID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
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
-(ApigeeClientResponse *)disconnectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeID:(NSString *)connecteeID
{
    NSString *url = [self createURL:connectorType append2:connectorID append3:connectionType append4:connecteeID];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
}

-(ApigeeClientResponse *)getEntityConnections: (NSString *)connectorType connectorID:(NSString *)connectorID connectionType:(NSString *)connectionType query:(ApigeeQuery *)query
{
    NSMutableString *url = [self createURL:connectorType append2:connectorID append3:connectionType];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];
}

/************************** MESSAGE MANAGEMENT **************************/
/************************** MESSAGE MANAGEMENT **************************/
/************************** MESSAGE MANAGEMENT **************************/
-(ApigeeClientResponse *)postMessage: (NSString *)queuePath message:(NSDictionary *)message
{
    // because the NSDictionary is from the client, we can't trust it. We need 
    // to go throApigeeh full error checking
    NSString *error;
    NSString *jsonStr = [self createJSON:message error:&error];
    
    if ( !jsonStr )
    {
        // report the error
        ApigeeClientResponse *ret = [[ApigeeClientResponse alloc] initWithDataClient:self];
        [ret setTransactionID:-1];
        [ret setTransactionState:kApigeeClientResponseFailure];
        [ret setResponse:error];
        [ret setRawResponse:nil];
        return ret;
    }
    
    // make the path and fire it off
    NSString *url = [self createURL:@"queues" append2:queuePath];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:jsonStr];
}

-(ApigeeClientResponse *)getMessages: (NSString *)queuePath query:(ApigeeQuery *)query;
{
    NSMutableString *url = [self createURL:@"queues" append2:queuePath];
    [self appendQueryToURL:url query:query];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

-(ApigeeClientResponse *)addSubscriber: (NSString *)queuePath subscriberPath:(NSString *)subscriberPath
{
    NSString *url = [self createURL:@"queues" append2:queuePath append3:@"subscribers" append4:subscriberPath];
    return [self httpTransaction:url op:kApigeeHTTPPost opData:nil];
}

-(ApigeeClientResponse *)removeSubscriber: (NSString *)queuePath subscriberPath:(NSString *)subscriberPath
{
    NSString *url = [self createURL:@"queues" append2:queuePath append3:@"subscribers" append4:subscriberPath];
    return [self httpTransaction:url op:kApigeeHTTPDelete opData:nil];
}


/*************************** SERVER-SIDE STORAGE ***************************/
/*************************** SERVER-SIDE STORAGE ***************************/
/*************************** SERVER-SIDE STORAGE ***************************/
// fun with uuids. Apple made this needlessly complex when they decided 
// developers were no longer allowed to access the device ID of the handset. 
+(NSString *)getUniqueDeviceID
{
    // first, see if we have the value cached
    if ( g_deviceUUID ) return g_deviceUUID;
    
    // next, see if we have the value in our database
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ( !defaults ) return nil; // serious problems
    g_deviceUUID = [defaults valueForKey:@"ApigeeClientDeviceUUID"];

    // if we did, we're good
    if ( g_deviceUUID ) return g_deviceUUID;
    
    // if we're here, we need to create a unique ID
    CFUUIDRef uuidRef = CFUUIDCreate(nil);
    CFStringRef uuidStringRef = CFUUIDCreateString(nil, uuidRef);
    CFRelease(uuidRef);
    
    // convert it to a usable string. Make our own copy.
    g_deviceUUID = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
    if ( !g_deviceUUID ) return nil;

    // store it
    [defaults setObject:g_deviceUUID forKey:@"ApigeeClientDeviceUUID"];
    [defaults synchronize];
    
    // done
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
        [ret setTransactionID:-1];
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

-(ApigeeClientResponse *)getRemoteStorage
{
    NSString *handsetUUID = [ApigeeDataClient getUniqueDeviceID];
    NSString *url = [self createURL:@"devices" append2:handsetUUID];
    return [self httpTransaction:url op:kApigeeHTTPGet opData:nil];
}

/***************************** OBLIQUE USAGE ******************************/
-(ApigeeClientResponse *)apiRequest: (NSString *)url operation:(NSString *)op data:(NSString *)opData
{
    // work out the op to use
    int opID = kApigeeHTTPGet;
    if ( [op isEqualToString:@"GET"] ) opID = kApigeeHTTPGet;
    if ( [op isEqualToString:@"POST"] ) opID = kApigeeHTTPPost;
    if ( [op isEqualToString:@"POSTFORM"] ) opID = kApigeeHTTPPostAuth;
    if ( [op isEqualToString:@"PUT"] ) opID = kApigeeHTTPPut;
    if ( [op isEqualToString:@"DELETE"] ) opID = kApigeeHTTPDelete;
    
    // fire it off. The data, formatting, etc. is all the client's problem. 
    // That's the way oblique functionality is. 
    return [self httpTransaction:url op:opID opData:opData];
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

+(void)setLogger:(id<ApigeeLogger>)aLogger
{
    logger = aLogger;
}


//****************************  MISC  *************************************
+(BOOL)isUuidValid:(NSString*)uuid
{
    //TODO: how to properly validate uuid?
    return [uuid length] > 0;
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
    return [self getCollection:type query:nil];
}

-(ApigeeCollection*)getCollection:(NSString*)type query:(NSDictionary*)qs
{
    return [[ApigeeCollection alloc] init:self type:type qs:qs];
}


@end


