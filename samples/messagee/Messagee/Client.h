//
//  Client.h
//  Messagee
//
//  Copyright (c) 2012 Apigee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ApigeeiOSSDK/Apigee.h>


@interface Client : NSObject

@property (nonatomic, strong) ApigeeDataClient *usergridClient;
@property (nonatomic, strong) ApigeeUser *user;

-(BOOL)login:(NSString*)username
        withPassword:(NSString*)password;

-(void)login:(NSString*)username
withPassword:(NSString*)password
completionHandler:(void (^)(BOOL loginSucceeded))completionBlock;

-(BOOL)createUser:(NSString*)username
         withName:(NSString*)name
        withEmail:(NSString*)email
     withPassword:(NSString*)password;

-(void)createUser:(NSString*)username
        withName:(NSString*)name
        withEmail:(NSString*)email
        withPassword:(NSString*)password
completionHandler:(void (^)(BOOL userCreatedAndLoggedIn))completionBlock;

-(BOOL)postMessage:(NSString*)message;

-(void)postMessage:(NSString*)message
 completionHandler:(void (^)(ApigeeClientResponse *response))completionBlock;


-(NSArray*)getMessages;

-(void)getMessages:(void (^)(NSArray *messages))completionBlock;

-(NSArray*)getFollowing;

-(void)getFollowing:(void (^)(NSArray *following))completionBlock;

-(BOOL)followUser:(NSString*)username;

-(void)followUser:(NSString*)username completionHandler:(void (^)(ApigeeClientResponse *response))completionBlock;


@end
