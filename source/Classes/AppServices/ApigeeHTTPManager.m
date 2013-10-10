#import "ApigeeHTTPManager.h"
#import "ApigeeHTTPResult.h"

// all transaction IDs are unique across all ApigeeHTTPManagers. 
// this global increases every time there's an asynchronous 
// transaction. 
static int g_nextTransactionID = 1;

static const int kInvalidTransactionID = -1;

// a mutex to protect against multiple threads getting
// IDs at the same time, and possibly getting the same ID
// because of it
NSRecursiveLock *g_transactionIDLock = nil;

@interface ApigeeHTTPManager ()

@property (nonatomic, copy) ApigeeHTTPCompletionHandler completionHandler;
@property (nonatomic, copy) NSHTTPURLResponse *httpResponse;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end


@implementation ApigeeHTTPManager
{
    // data management for collecting incoming HTTP data
    // during asynch transactions
    NSMutableData *m_receivedData;
    
    // a general error string
    NSString *m_lastError;
    
    // the delegate sent in to the asynch method
    id m_delegate;
    
    // the transaction ID of the current (or most recent) transaction
    int m_transactionID;
    
    // availability of this instance. Managed by ApigeeClient
    BOOL m_bAvailable;
    
    // mutex used to ensure the delegate is not changed
    // in a way that would cause a race condition.
    NSRecursiveLock *m_delegateLock;        
    
    // the auth key to send along to requests
    NSString *m_auth;
    
    // custom HTTP headers
    NSMutableDictionary *m_dictCustomHTTPHeaders;
}

@synthesize completionHandler;
@synthesize httpResponse;
@synthesize operationQueue;

-(id)init
{
    self = [super init];
    if ( self )
    {
        m_lastError = @"No error";
        m_receivedData = [NSMutableData data];
        m_bAvailable = YES;
        m_delegateLock = [NSRecursiveLock new];
        m_transactionID = kInvalidTransactionID;
        m_auth = nil;
        self.operationQueue = [[NSOperationQueue alloc] init];
        m_dictCustomHTTPHeaders = nil;
        
        // lazy-init the transaction lock
        if ( !g_transactionIDLock )
        {
            g_transactionIDLock = [NSRecursiveLock new];
        }
    }
    return self;
}

-(void)setAuth: (NSString *)auth
{
    m_auth = auth;
}

-(NSString *)getLastError
{
    return m_lastError;
}

-(int)getNextTransactionID
{
    // make sure we can use this lock
    assert(g_transactionIDLock);
    
    [g_transactionIDLock lock];
    int ret = g_nextTransactionID++;
    [g_transactionIDLock unlock];
    
    return ret;
}

-(int)getTransactionID
{
    return m_transactionID;
}


//----------------------- SYNCHRONOUS CALLING ------------------------
-(NSString *)syncTransaction:(NSString *)url operation:(int)op operationData:(NSString *)opData;
{
    // clear the transaction ID
    m_transactionID = kInvalidTransactionID;
    
    // use the synchronous funcitonality of NSURLConnection
    // clear the error
    m_lastError = @"No error";
    
    // formulate the request
    NSURLRequest *req = [self getRequest:url operation:op operationData:opData];
    
    NSURLResponse *response;
    NSError *error;
    NSData *resultData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if ( resultData )
    {
        // we got results
        NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];        
        return resultString;
    }
    
    // if we're here, it means we got nil as the result
    m_lastError = [error localizedDescription];
    return nil;
}

//----------------------- ASYNCHRONOUS CALLING ------------------------
-(int)asyncTransaction:(NSString *)url operation:(int)op operationData:(NSString *)opData delegate:(id)delegate;
{
    // clear the transaction ID
    m_transactionID = kInvalidTransactionID;
    
    // clear the error
    m_lastError = @"No error";
    
    if ( !delegate )
    {
        // an asynch transaction with no delegate has no meaning
        m_lastError = @"Delegate was nil";
        return kInvalidTransactionID;
    }
    
    // make sure the delegate responds to the various messages that
    // are required
    if ( ![delegate respondsToSelector:@selector(httpManagerError:error:)] )
    {
        m_lastError = @"Delegate does not have httpManagerError:error: method";
        return kInvalidTransactionID;
    }
    if ( ![delegate respondsToSelector:@selector(httpManagerResponse:response:)] )
    {
        m_lastError = @"Delegate does not have httpManagerResponse:response: method";
        return kInvalidTransactionID;
    }
    
    // only once we're assured everything is right do we set the internal value
    [m_delegateLock lock];
    m_delegate = delegate;
    [m_delegateLock unlock];
    
    self.completionHandler = nil;
    
    // prep a transaction ID for this transaction
    m_transactionID = [self getNextTransactionID];
   
    // formulate the request
    NSURLRequest *req = [self getRequest:url operation:op operationData:opData];
        
    // fire it off
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    // Note failure
    if ( !conn )
    {
        // failed to connect
        m_lastError = @"Unable to initiate connection.";
        return kInvalidTransactionID;       
    }
    
    // success
    return m_transactionID;
}

-(int)asyncTransaction:(NSString *)url operation:(int)op operationData:(NSString *)opData completionHandler:(ApigeeHTTPCompletionHandler) theCompletionHandler
{
    // clear the transaction ID
    m_transactionID = kInvalidTransactionID;
    
    // clear the error
    m_lastError = @"No error";
    
    if ( !theCompletionHandler )
    {
        // an asynch transaction with no completion handler has no meaning
        m_lastError = @"Completion handler was nil";
        return kInvalidTransactionID;
    }
    
    self.completionHandler = theCompletionHandler;

    [m_delegateLock lock];
    m_delegate = nil;
    [m_delegateLock unlock];

    // prep a transaction ID for this transaction
    m_transactionID = [self getNextTransactionID];
    
    // formulate the request
    NSURLRequest *req = [self getRequest:url operation:op operationData:opData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:queue
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
                               ApigeeHTTPResult *result = [[ApigeeHTTPResult alloc] init];
                               
                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   result.response = (NSHTTPURLResponse*) response;
                               }
                               
                               result.data = data;
                               result.error = error;
                               result.object = nil;
                               
                               if (![NSThread isMainThread]) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                        theCompletionHandler(result,self);
                                   });
                               } else {
                                   // we're already on the main thread
                                   theCompletionHandler(result,self);
                               }
                           }];
    
    return m_transactionID;
}

-(BOOL)isAvailable
{
    return m_bAvailable;
}

-(void)setAvailable:(BOOL)available
{
    m_bAvailable = available;
}

-(void)cancel
{
    // we wrap this in a lock to ensure that the client can
    // call it at any time. It will not cause a race condition in 
    // any callback thread.
    [m_delegateLock lock];
    m_delegate = nil;
    [m_delegateLock unlock];
    
    self.completionHandler = nil;
    
    // note that we do not modify the "in use" flag. If we werei n use,
    // we remain in use until we receive a response or error. This ensures 
    // no confusion on any subsequent transaction. We don't want the case 
    // where a transaction is started, then cancelled, then a new transaction begun
    // before the first transaction's result comes in. That would lead to the second 
    // transaction being answered with the first's reply. We avoid that possibility by
    // simply remaining "in use" until we get the reply or error.
}

// general helper function for making escaped-strings
+(NSString *)escapeSpecials:(NSString *)raw;
{
    NSString *converted = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)raw, nil, CFSTR(";/?:@&=$+{}<>"), kCFStringEncodingUTF8);
    return converted;
}

// INTERNAL function for forming the request
-(NSURLRequest *)getRequest:(NSString *)url operation:(int)op operationData:(NSString *)opStr;
{
    // make the url
    NSURL *nsurl = [NSURL URLWithString:url];
        
    NSMutableURLRequest *req = [NSMutableURLRequest new];
    [req setURL:nsurl];
    
    switch ( op ) 
    {
        case kApigeeHTTPGet: [req setHTTPMethod:@"GET"]; break;
        case kApigeeHTTPPost: [req setHTTPMethod:@"POST"]; break;
        case kApigeeHTTPPostAuth: [req setHTTPMethod:@"POST"]; break;
        case kApigeeHTTPPut: [req setHTTPMethod:@"PUT"]; break;
        case kApigeeHTTPDelete: [req setHTTPMethod:@"DELETE"]; break;
    }

    // set the auth, if any is available
    if ( m_auth )
    {
        NSMutableString *authStr = [NSMutableString new];
        [authStr appendFormat:@"Bearer %@", m_auth];
        [req setValue:authStr forHTTPHeaderField:@"Authorization"];
    }
    
    // set the custom headers, if any
    if ( m_dictCustomHTTPHeaders )
    {
        NSArray *allHeaderFields = [m_dictCustomHTTPHeaders allKeys];
        for ( NSString *field in allHeaderFields )
        {
            NSString *value = [m_dictCustomHTTPHeaders valueForKey:field];
            [req setValue:value forHTTPHeaderField:field];
        }
    }

    // if they sent an opStr, we make that the content
    if ( opStr )
    {
        // prep the post data
        NSData *opData = [opStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        // make a string that tells the length of the post data. We'll need that for the HTTP header setup
        NSString *opLength = [NSString stringWithFormat:@"%d", [opData length]];
        
        [req setValue:opLength forHTTPHeaderField:@"Content-Length"];
        
        // PostAuth uses form encoding. All other operations use json
        if ( op == kApigeeHTTPPostAuth )
        {
            [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        else
        {
            [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        
        [req setHTTPBody:opData];
    }
    
    // all set up and ready for use
    return req;
    
}

//------------------------------------------------------------------------------------------
//-------------------------- NSURLCONNECTION DELEGATE METHODS ------------------------------
//------------------------------------------------------------------------------------------
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ( [response isKindOfClass:[NSHTTPURLResponse class]] ) {
        
        self.httpResponse = (NSHTTPURLResponse*) response;
    }
    
    // got a response. clear out the data
    [m_receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // got some data. Append it.
    [m_receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
     // connection failed. Note the error
    m_lastError = [error localizedDescription];
    
    // send the error to the delegate. We wrap this in 
    // send the result to the delegate.
    // wrap this in mutex locks, then check for validity of m_delegate inside.
    // this ensures no race conditions and allows arbitrary cancellation of callbacks
    if ( m_delegate ) {
        [m_delegateLock lock];
        [m_delegate performSelector:@selector(httpManagerError:error:) withObject:self withObject:m_lastError];
        m_delegate = nil;
        [m_delegateLock unlock];
    } else if ( self.completionHandler != nil ) {
        self.completionHandler = nil;
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    // send it to the delegate. See connection:didFailWithError: for an explanation
    // of the mutex locks
    if ( m_delegate ) {
        NSString *resultString = [[NSString alloc] initWithData:m_receivedData encoding:NSUTF8StringEncoding];
        [m_delegateLock lock];
        [m_delegate performSelector:@selector(httpManagerResponse:response:) withObject:self withObject:resultString];
        m_delegate = nil;
        [m_delegateLock unlock];
    } else if ( self.completionHandler != nil ) {
        ApigeeHTTPResult *result = [[ApigeeHTTPResult alloc] init];
        result.data = m_receivedData;
        result.response = self.httpResponse;
        result.error = nil;
        self.completionHandler(result,self);
        self.completionHandler = nil;
    }
}

//**********************  HTTP HEADERS  **************************
-(void)addHTTPHeaderField:(NSString*)field withValue:(NSString*)value
{
    if ( ! m_dictCustomHTTPHeaders ) {
        m_dictCustomHTTPHeaders = [[NSMutableDictionary alloc] init];
    }
    
    [m_dictCustomHTTPHeaders setValue:value forKey:field];
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
    }
}

-(NSArray*)HTTPHeaderFields
{
    if ( m_dictCustomHTTPHeaders ) {
        return [m_dictCustomHTTPHeaders allKeys];
    }
    
    return nil;
}

@end
