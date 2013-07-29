#import <Foundation/Foundation.h>
#import "ApigeeClientResponse.h"
#import "ApigeeQuery.h"
#import "ApigeeActivity.h"
#import "ApigeeUser.h"
//#import "ApigeeLogger.h"

/******************** A WORD ON NETWORK COMMUNICATION CALLS ****************
Some calls require network communication with UserGrid. Therefore,
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

typedef void (^ApigeeDataClientCompletionHandler)(ApigeeClientResponse *response);


@interface ApigeeDataClient : NSObject

+(NSString *) version;

+(NSString*)defaultBaseURL;

/********************* INIT AND SETUP *********************/
// init with an org ID and app ID
-(id) initWithOrganizationId: (NSString *)organizationID withApplicationID:(NSString *)applicationID;

// init with an org ID, app ID, and a base UserGrid URL. This is useful if you
// are running a local Apigee server or your company has its own public
// Apigee server. The default URL is http://api.usergrid.com. The base URL
// must be a fully formatted http link, including the "http://" at the
// beginning.
-(id) initWithOrganizationId: (NSString *)organizationID withApplicationID:(NSString *)applicationID baseURL:(NSString *)baseURL;

// set the delegate. See "A WORD ON NETWORK COMMUNICATION CALLS"
// at the top of the file for a detailed explanation. The function
// will return NO if the delegate is rejected. This means the delegate
// does not support the required delegation function "ApigeeClientResponse".
//
// This is the formal declaration of ApigeeClientResponse:
// -(void)ApigeeClientResponse:(ApigeeClientResponse *)response
// 
// You may change the delegate at any time, but be forewarned that any
// pending transactions in progress will be abandoned. Changing the delegate
// (especially setting it to nil) ensures that hte previous delegate will
// receive no further messages from this instance of ApigeeClient. 
// 
// Setting the delegate to nil puts the API in to synchronous mode.
-(BOOL) setDelegate:(id)delegate;


/********************* LOGIN / LOGOUT *********************/
// log in with the given username and password
-(ApigeeClientResponse *)logInUser: (NSString *)userName password:(NSString *)password;

-(ApigeeClientResponse *)logInUser: (NSString *)userName password:(NSString *)password completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// log in with the given username and PIN value
-(ApigeeClientResponse *)logInUserWithPin: (NSString *)userName pin:(NSString *)pin;

-(ApigeeClientResponse *)logInUserWithPin: (NSString *)userName pin:(NSString *)pin completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// log in user with Facebook token
-(ApigeeClientResponse *)logInUserWithFacebook: (NSString *)facebookToken;

-(ApigeeClientResponse *)logInUserWithFacebook: (NSString *)facebookToken completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// log in as the administrator of the application. Generally used for applications
// that have an "administrator" feature. Not the sort of thing you want normal
// users doing. 
-(ApigeeClientResponse *)logInAdmin: (NSString *)adminUserName secret:(NSString *)adminSecret;

-(ApigeeClientResponse *)logInAdmin: (NSString *)adminUserName secret:(NSString *)adminSecret completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// log out the current user. The Client only supports one user logged in at a time.
// You can have multiple instances of ApigeeClient if you want multiple
// users doing transactions simultaneously. This does not require network communication,
// so it has no return. It doesn't actually "log out" from the server. It simply clears 
// the locally stored auth information
-(void)logOut;



/********************* USER MANAGEMENT *********************/
//adds a new user
-(ApigeeClientResponse *)addUser:(NSString *)username email:(NSString *)email name:(NSString *)name password:(NSString *)password;

-(ApigeeClientResponse *)addUser:(NSString *)username email:(NSString *)email name:(NSString *)name password:(NSString *)password completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// updates a user's password
-(ApigeeClientResponse *)updateUserPassword:(NSString *)usernameOrEmail oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;

-(ApigeeClientResponse *)updateUserPassword:(NSString *)usernameOrEmail oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// get all the groups this user is in
-(ApigeeClientResponse *)getGroupsForUser: (NSString *)userID;

-(ApigeeClientResponse *)getGroupsForUser: (NSString *)userID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// get users in this app. Definitely want to consider sending a Query along
// with this call
-(ApigeeClientResponse *)getUsers: (ApigeeQuery *)query;

-(ApigeeClientResponse *)getUsers: (ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/********************* ACTIVITY MANAGEMENT *********************/
// create a new activity. 
// Note that there is a class, ApigeeActivity, which can help
// you create and validate an Activity, and will generate the needed
// NSDictionary for you.
-(ApigeeClientResponse *)createActivity: (NSDictionary *)activity;

-(ApigeeClientResponse *)createActivity: (NSDictionary *)activity completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// create an activity and post it to a user in a single step. See comment
// above createActivity for information on making Activity creation easier
-(ApigeeClientResponse *)postUserActivity: (NSString *)userID properties:(NSDictionary *)activityProperties;

-(ApigeeClientResponse *)postUserActivity: (NSString *)userID activity:(ApigeeActivity *)activity;

-(ApigeeClientResponse *)postUserActivity: (NSString *)userID properties:(NSDictionary *)activityProperties completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

-(ApigeeClientResponse *)postUserActivity: (NSString *)userID activity:(ApigeeActivity *)activity completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;


// post an already-created activity to a user
-(ApigeeClientResponse *)postUserActivityByUUID: (NSString *)userID activity:(NSString *)activityUUID;

-(ApigeeClientResponse *)postUserActivityByUUID: (NSString *)userID activity:(NSString *)activityUUID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// create an activity and post it to a group in a single step. See comment
// above createActivity for information on making Activity creation easier
-(ApigeeClientResponse *)postGroupActivity: (NSString *)groupID properties:(NSDictionary *)activityProperties;

-(ApigeeClientResponse *)postGroupActivity:(NSString *)groupID activity:(ApigeeActivity *)activity;

-(ApigeeClientResponse *)postGroupActivity: (NSString *)groupID properties:(NSDictionary *)activityProperties completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

-(ApigeeClientResponse *)postGroupActivity:(NSString *)groupID activity:(ApigeeActivity *)activity completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// post an already-created activity to a group
-(ApigeeClientResponse *)postGroupActivityByUUID: (NSString *)groupID activity:(NSString *)activityUUID;

-(ApigeeClientResponse *)postGroupActivityByUUID: (NSString *)groupID activity:(NSString *)activityUUID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// get the activities this user is in
-(ApigeeClientResponse *)getActivitiesForUser: (NSString *)userID query:(ApigeeQuery *)query;

-(ApigeeClientResponse *)getActivitiesForUser: (NSString *)userID query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// get the activities this group is in
-(ApigeeClientResponse *)getActivitiesForGroup: (NSString *)groupID query:(ApigeeQuery *)query;

-(ApigeeClientResponse *)getActivitiesForGroup: (NSString *)groupID query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// get the activity feed for a user
-(ApigeeClientResponse *)getActivityFeedForUser: (NSString *)userID query:(ApigeeQuery *)query;

-(ApigeeClientResponse *)getActivityFeedForUser: (NSString *)userID query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// get the activity feed for a group
-(ApigeeClientResponse *)getActivityFeedForGroup: (NSString *)groupID query:(ApigeeQuery *)query;

-(ApigeeClientResponse *)getActivityFeedForGroup: (NSString *)groupID query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// remove an activity 
-(ApigeeClientResponse *)removeActivity:(NSString *)activityUUID;

-(ApigeeClientResponse *)removeActivity:(NSString *)activityUUID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/********************* GROUP MANAGEMENT *********************/
// create a new group. The groupPath can be a path with slashes to make for
// a hierarchical structure of your own design (if you want). groupTitle is
// optional, you can send nil if you don't want to provide one.
-(ApigeeClientResponse *)createGroup:(NSString *)groupPath groupTitle:(NSString *)groupTitle;

-(ApigeeClientResponse *)createGroup:(NSString *)groupPath groupTitle:(NSString *)groupTitle completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// add a user to a group
-(ApigeeClientResponse *)addUserToGroup:(NSString *)userID group:(NSString *)groupID;

-(ApigeeClientResponse *)addUserToGroup:(NSString *)userID group:(NSString *)groupID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// remove a user from a group
-(ApigeeClientResponse *)removeUserFromGroup:(NSString *)userID group:(NSString *)groupID;

-(ApigeeClientResponse *)removeUserFromGroup:(NSString *)userID group:(NSString *)groupID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// get all the users in this group
-(ApigeeClientResponse *)getUsersForGroup:(NSString *)groupID query:(ApigeeQuery *)query;

-(ApigeeClientResponse *)getUsersForGroup:(NSString *)groupID query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;


/******************** ENTITY MANAGEMENT ********************/
// adds an entity to the specified collection. 
-(ApigeeClientResponse *)createEntity: (NSDictionary *)newEntity;

-(ApigeeClientResponse *)createEntity: (NSDictionary *)newEntity
                    completionHandler: (ApigeeDataClientCompletionHandler) completionHandler;


// get a list of entities that meet the specified query.
-(ApigeeClientResponse *)getEntities: (NSString *)type query:(ApigeeQuery *)query;

-(ApigeeClientResponse *)getEntities: (NSString *)type query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

-(ApigeeClientResponse *)getEntities: (NSString *)type queryString:(NSString *)queryString;

-(ApigeeClientResponse *)getEntities: (NSString *)type queryString:(NSString *)queryString completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// updates an entity (it knows the type from the entity data) 
-(ApigeeClientResponse *)updateEntity: (NSString *)entityID entity:(NSDictionary *)updatedEntity;

-(ApigeeClientResponse *)updateEntity: (NSString *)entityID entity:(NSDictionary *)updatedEntity completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// removes an entity of the specified type
-(ApigeeClientResponse *)removeEntity: (NSString *)type entityID:(NSString *)entityID;

-(ApigeeClientResponse *)removeEntity: (NSString *)type entityID:(NSString *)entityID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// Directionally connect two entities. For instance, user "Bob" might like Lyons Restaurant.
// connectorType would be "users" (because Bob is a user)
// connectorID would be Bob's userID
// connectionType would be "like"
// connecteeID would be the UUID of Lyons Restaurant
-(ApigeeClientResponse *)connectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeID:(NSString *)connecteeID;

-(ApigeeClientResponse *)connectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeID:(NSString *)connecteeID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// Directionally connect two entities. For instance, user "Bob" might follow user "Mary".
// connectorType would be "users" (because Bob is a user)
// connectorID would be Bob's userID
// connectionType would be "like"
// connecteeType would  be "users" (because Mary is a user)
// connecteeID would be Mary's userID
-(ApigeeClientResponse *)connectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID connectionType:(NSString *)connectionType connecteeType:(NSString *)connecteeType connecteeID:(NSString *)connecteeID;

-(ApigeeClientResponse *)connectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID connectionType:(NSString *)connectionType connecteeType:(NSString *)connecteeType connecteeID:(NSString *)connecteeID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// disconnect two entities. It uses the same parameters and calling rules as connectEntities
-(ApigeeClientResponse *)disconnectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeID:(NSString *)connecteeID;

-(ApigeeClientResponse *)disconnectEntities: (NSString *)connectorType connectorID:(NSString *)connectorID type:(NSString *)connectionType connecteeID:(NSString *)connecteeID completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// get entity connections
-(ApigeeClientResponse *)getEntityConnections: (NSString *)connectorType connectorID:(NSString *)connectorID connectionType:(NSString *)connectionType query:(ApigeeQuery *)query;

-(ApigeeClientResponse *)getEntityConnections: (NSString *)connectorType connectorID:(NSString *)connectorID connectionType:(NSString *)connectionType query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;


/********************* MESSAGE MANAGEMENT *********************/
// post a message to a given queue
-(ApigeeClientResponse *)postMessage: (NSString *)queuePath message:(NSDictionary *)message;

-(ApigeeClientResponse *)postMessage: (NSString *)queuePath message:(NSDictionary *)message completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// get all messages from the queue path
-(ApigeeClientResponse *)getMessages: (NSString *)queuePath query:(ApigeeQuery *)query;

-(ApigeeClientResponse *)getMessages: (NSString *)queuePath query:(ApigeeQuery *)query completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// add a subscriber to a queue
-(ApigeeClientResponse *)addSubscriber: (NSString *)queuePath subscriberPath:(NSString *)subscriberPath;

-(ApigeeClientResponse *)addSubscriber: (NSString *)queuePath subscriberPath:(NSString *)subscriberPath completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// remove a subscriber from a queue
-(ApigeeClientResponse *)removeSubscriber: (NSString *)queuePath subscriberPath:(NSString *)subscriberPath;

-(ApigeeClientResponse *)removeSubscriber: (NSString *)queuePath subscriberPath:(NSString *)subscriberPath completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;


/********************* SERVER-SIDE STORAGE *********************/
// these functions refer to data that can be put in a special place 
// specific to this device. Every call to remoteStorage replaces whatever 
// was there before

// put the data in to the remote storage
-(ApigeeClientResponse *)setRemoteStorage: (NSDictionary *)data;

-(ApigeeClientResponse *)setRemoteStorage: (NSDictionary *)data completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;


// get the data from remote storage
-(ApigeeClientResponse *)getRemoteStorage;

-(ApigeeClientResponse *)getRemoteStorage:(ApigeeDataClientCompletionHandler)completionHandler;

// a class function that returns a uuid for this
// device. It will be globally unique, and will always
// return the same value for the same handset.
// NOTE - This value will change if the operating
// system is reinstalled. This function is used internally, but
// is also handy for clients, so it is part of the interface.
+(NSString *)getUniqueDeviceID;

/*********************** REMOTE PUSH NOTIFICATIONS ************************/
// call from application:didRegisterForRemoteNotificationsWithDeviceToken: callback
// will automaticaly register the passed deviceToken with the usergrid system
// using the getUniqueDeviceID method to associate this device on the server
- (ApigeeClientResponse *)setDevicePushToken:(NSData *)newDeviceToken forNotifier:(NSString *)notifier;

- (ApigeeClientResponse *)setDevicePushToken:(NSData *)newDeviceToken forNotifier:(NSString *)notifier completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

// push an "alert" type notification to the remote group, user, or device specified
// in the path argument. the notifier may be a name or UUID of an apns notifier
// that has been set up on the usergrid server.
- (ApigeeClientResponse *)pushAlert:(NSString *)message
                          withSound:(NSString *)sound
                                 to:(NSString *)path
                      usingNotifier:(NSString *)notifier;

- (ApigeeClientResponse *)pushAlert:(NSString *)message
                          withSound:(NSString *)sound
                                 to:(NSString *)path
                      usingNotifier:(NSString *)notifier
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*********************** ACCESSORS ************************/
// if a user is logged in, this returns the OAuth token for this session. 
// ApigeeDataClient manages this internally, so you never really need it. But if you
// want it for other reasons, this accessor gives it to you. If you have not
// successfully logged in, this will return nil
-(NSString *)getAccessToken;

// returns information about the logged in user
-(ApigeeUser *)getLoggedInUser;

// returns the delegate that is currently being used for asynch
// calls. Returns nil if there is no delegate (synch mode)
-(id) getDelegate;

/*********************** OBLIQUE USAGE ************************/
// This is a general purpose function for directly accessing the
// UserGrid service. This is useful if the service has new features 
// that the API has not yet supported, or if you are using an older 
// version of the API and don't want to upgrade.
// 
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
//         doing. Bear in mind that this api comes with SBJson, which provides
//         some very simple ways to assemble json formatted strings. See SBJsonWriter.
//
// NOTE - This function will be synchronous or asynchronous the same as any
// other function in the API. It is based on the value sent to setDelegate.
-(ApigeeClientResponse *)apiRequest: (NSString *)url operation:(NSString *)op data:(NSString *)opData;

-(ApigeeClientResponse *)apiRequest:(NSString *)url
                          operation:(NSString *)op
                               data:(NSString *)opData
                  completionHandler:(ApigeeDataClientCompletionHandler)completionHandler;

/*********************** DEBUGGING ASSISTANCE ************************/
// when logging is on, all outgoing URLs are logged via NSLog, and all
// incoming data from the service is also logged. Additionally, any errors
// encountered internally are logged. This can be helpful to see the actual
// service communication in progress and help debApigee problems you may be having. 
-(void)setLogging: (BOOL)loggingState;

-(void)writeLog:(NSString*)logMessage;
//+(void)setLogger:(id<ApigeeLogger>)aLogger;

//**********************  MISC  ******************************
+(BOOL)isUuidValid:(NSString*)uuid;
- (ApigeeEntity*)createTypedEntity:(NSString*)type;


//**********************  COLLECTION  ************************
-(ApigeeCollection*)getCollection:(NSString*)type;
-(ApigeeCollection*)getCollection:(NSString*)type query:(NSDictionary*)qs;

/*********************** VERSION CHECKING ************************/
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@end
