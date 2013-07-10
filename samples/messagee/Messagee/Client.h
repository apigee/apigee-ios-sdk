//
//  Client.h
//  Messagee
//
//  Created by Rod Simpson on 12/27/12.
//  Copyright (c) 2012 Rod Simpson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApigeeiOSSDK/ApigeeDataClient.h>


@interface Client : NSObject

@property (nonatomic, strong) ApigeeDataClient *usergridClient;
@property (nonatomic, strong) ApigeeUser *user;

-(bool)login:(NSString*)username
        withPassword:(NSString*)password;

-(bool)createUser:(NSString*)username
        withName:(NSString*)name
        withEmail:(NSString*)email
        withPassword:(NSString*)password;

-(bool)postMessage:(NSString*)message;


-(NSArray*)getMessages;

-(NSArray*)getFollowing;

-(bool)followUser:(NSString*)username;


@end
