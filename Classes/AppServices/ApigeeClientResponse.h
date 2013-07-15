#import <Foundation/Foundation.h>


// response states
enum
{
    kApigeeClientResponseSuccess = 0,
    kApigeeClientResponseFailure = 1,
    kApigeeClientResponsePending = 2
};

@class ApigeeEntity;
@class ApigeeDataClient;
@class ApigeeUser;


@interface ApigeeClientResponse : NSObject

// this will be a unique ID for this transaction. If you have
// multiple transactions in progress, you can keep track of them
// with this value. Note: The transaction ID of a synchronous
// call response is always -1.
@property int transactionID;

// this will be one of three possible valuse:
// kApigeeClientResponseSuccess: The operation is complete and was successful. response will 
//                          be valid, as will rawResponse
//
// kApigeeClientResponseFailure: There was an error with the operation. No further 
//                          processing will be done. response will be an NSString with
//                          a plain-text description of what went wrong. rawResponse
//                          will be valid if the error occurred after receiving data from
//                          the service. If it occurred before, rawResponse will be nil.
//
// kApigeeClientResponsePending: The call is being handled asynchronously and not yet complete. 
//                          response will be nil. rawResponse will also be nil
@property int transactionState;

// This is the response. The type of this variable is dependant on the call that caused
// this response. 
@property (unsafe_unretained) id response;

// This is the raw text that was returned by the server. 
@property (unsafe_unretained) NSString *rawResponse;
@property (unsafe_unretained) ApigeeDataClient *dataClient;

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


- (id)initWithDataClient:(ApigeeDataClient*)theDataClient;

- (int)entityCount;
- (NSArray*)entities;
- (ApigeeEntity*)firstEntity;
- (ApigeeEntity*)lastEntity;
- (void)parse:(NSString*)serverResponse;

- (BOOL)completedSuccessfully;

@end
